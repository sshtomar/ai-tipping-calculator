"""Tippy dev server — static files + Claude API proxy."""

import http.server
import json
import urllib.request
import ssl
import os

PORT = 8080
CLAUDE_API_KEY = os.environ.get("CLAUDE_API_KEY", "")
CLAUDE_MODEL = "claude-sonnet-4-5-20250929"
CLAUDE_ENDPOINT = "https://api.anthropic.com/v1/messages"


class TippyHandler(http.server.SimpleHTTPRequestHandler):

    def do_POST(self):
        if self.path == "/api/analyze-receipt":
            self._handle_analyze()
        else:
            self.send_error(404)

    def _handle_analyze(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length))
        base64_image = body.get("image", "")
        media_type = body.get("mediaType", "image/jpeg")

        payload = json.dumps({
            "model": CLAUDE_MODEL,
            "max_tokens": 512,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image",
                            "source": {
                                "type": "base64",
                                "media_type": media_type,
                                "data": base64_image,
                            },
                        },
                        {
                            "type": "text",
                            "text": (
                                'Analyze this receipt image. Return ONLY a JSON object with these fields:\n'
                                '- "total": number (the final total amount charged, required)\n'
                                '- "subtotal": number or null\n'
                                '- "tax": number or null\n'
                                '- "serviceType": one of "restaurant","bar","cafe","delivery","rideshare",'
                                '"salon","spa","tattoo","valet","hotel","movers","other" or null\n'
                                '- "numberOfGuests": integer or null (look for guest/cover count)\n'
                                '- "venueName": string or null\n'
                                'Return ONLY valid JSON, no markdown, no explanation.'
                            ),
                        },
                    ],
                }
            ],
        }).encode()

        req = urllib.request.Request(
            CLAUDE_ENDPOINT,
            data=payload,
            headers={
                "Content-Type": "application/json",
                "x-api-key": CLAUDE_API_KEY,
                "anthropic-version": "2023-06-01",
            },
            method="POST",
        )

        ctx = ssl.create_default_context()

        try:
            with urllib.request.urlopen(req, timeout=30, context=ctx) as resp:
                data = json.loads(resp.read())
        except urllib.error.HTTPError as e:
            error_body = e.read().decode()
            self._json_response({"error": f"Claude API HTTP {e.code}", "detail": error_body}, status=502)
            return
        except Exception as e:
            self._json_response({"error": str(e)}, status=502)
            return

        # Extract text from Claude response
        text = ""
        for block in data.get("content", []):
            if block.get("type") == "text":
                text = block["text"]
                break

        if not text:
            self._json_response({"error": "No text in Claude response"}, status=502)
            return

        # Strip markdown fences
        cleaned = text.strip()
        if cleaned.startswith("```"):
            lines = cleaned.split("\n")
            lines = lines[1:]  # drop opening fence
            if lines and lines[-1].strip() == "```":
                lines = lines[:-1]
            cleaned = "\n".join(lines).strip()

        try:
            result = json.loads(cleaned)
        except json.JSONDecodeError:
            self._json_response({"error": "Failed to parse Claude JSON", "raw": cleaned}, status=502)
            return

        self._json_response(result)

    def _json_response(self, obj, status=200):
        body = json.dumps(obj).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # Quieter logs — skip static file GETs
        if args and "POST" in str(args[0]):
            super().log_message(fmt, *args)


if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    with http.server.HTTPServer(("", PORT), TippyHandler) as srv:
        print(f"Tippy dev server on http://localhost:{PORT}")
        srv.serve_forever()

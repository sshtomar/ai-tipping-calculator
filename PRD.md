# PRD: Tippy -- The 2026 AI-Driven Tipping Calculator (iOS)

**Version:** 1.0  
**Last Updated:** 2026-02-06  
**Status:** Draft  

---

## 1. Overview

Tippy is an iOS app that replaces the mental math and social anxiety of tipping with a single, confident recommendation powered by Claude. The user photographs their bill (or enters a total manually), provides minimal context about the situation, and receives a specific dollar amount, a percentage, and a brief, warm explanation of why that amount is right.

The product philosophy comes from a simple observation: nobody knows how to tip anymore. Not at restaurants, not for the gardener, not for the holiday season, not for the person who installed the window shades. Tipping in America is socially fraught, culturally inconsistent, and genuinely confusing. Tippy resolves that confusion with one clear answer grounded in a specific ethos: **the tip should never be memorable**. It should be generous enough that no one at the table would think you are stingy, but not so extravagant that the tip itself becomes the story of the evening. Everyone should feel at ease. The server is taken care of. The host is relaxed. The guest is not distracted. That is the target.

Inspired by the Hitchhiker's Guide to the Galaxy observation that the most complicated math in the universe is the math of a restaurant bill, Tippy treats tipping as a problem worthy of real intelligence -- not a percentage slider.

---

## 2. Goals

| # | Goal | Measure |
|---|------|---------|
| G1 | Eliminate tipping anxiety in under 10 seconds from photo to recommendation. | Time from camera shutter to recommendation displayed < 10s on median connection. |
| G2 | Provide recommendations that match or exceed the judgment of a socially fluent, generous American host. | >80% of user-rated recommendations marked "just right" in post-tip feedback (optional). |
| G3 | Cover the full spectrum of US tipping situations, not just restaurants. | App handles at least 12 distinct service categories at launch (see Section 6). |
| G4 | Be funny, warm, and opinionated -- not sterile. | Tone review by editorial pass; qualitative user feedback. |
| G5 | Respect privacy absolutely. No bill images or tip history leave the device. | Architecture audit; no network calls except Claude API with text-only payloads. |

---

## 3. Non-Goals (V1)

- **International tipping norms.** V1 is US-only. International support is a future version.
- **Bill splitting by line item.** We support dividing the total+tip by N people, but not assigning individual dishes to individuals.
- **Payment processing.** Tippy recommends; it does not pay. No Apple Pay, Venmo, or payment integrations.
- **Social features.** No sharing, leaderboards, or tipping profiles.
- **Apple Watch app.** iOS only.
- **Receipt archiving or expense tracking.** We do not store receipts or export to accounting tools.

---

## 4. Target Users and Use Cases

### Primary Persona

**Alex, 28-45, urban professional.** Eats out 3-5 times per week. Tips at restaurants on autopilot (usually 20%) but freezes when the context shifts: the holiday tip for the building doorman, the barber who squeezed them in, the Uber driver in the rain, the tattoo artist, the hotel housekeeper after a 4-night stay. Alex wants to do the right thing but genuinely does not know what the right thing is.

### Secondary Persona

**Jordan, 22-30, recent graduate.** New to professional social situations. Has been invited to a business dinner and is terrified of looking cheap or clueless. Wants a discreet, quick answer they can glance at under the table.

### Use Cases

| ID | Situation | Input | Expected Output |
|----|-----------|-------|-----------------|
| UC1 | Restaurant dinner, 4 people, business context | Photo of bill ($347.82) + "business dinner" | "Tip $73.00 (21%). This is a business dinner -- you want the tip to be invisible. 21% on a bill this size is generous without being performative. Total with tip: $420.82. Per person if splitting: $105.21." |
| UC2 | Coffee shop counter | Manual total ($6.50) + "counter service" | "Tip $1.50 (23%). Counter tips are smaller in absolute dollars but percentages run higher. A buck fifty on a coffee order is solid." |
| UC3 | Holiday tip for doorman | No bill; "doorman, holiday, NYC, 1 year" | "Tip $100-150. This is the standard holiday range for a doorman in a NYC building you've lived in for about a year. If they go above and beyond (packages, dry cleaning, always friendly), lean toward $150." |
| UC4 | Rideshare in the rain | Manual total ($23.40) + "rideshare, bad weather" | "Tip $6.00 (26%). Weather bumps it. They came out in the rain for you." |
| UC5 | Tattoo artist, 3-hour session | Manual total ($450) + "tattoo artist" | "Tip $90-110 (20-25%). Tattoo artists are tipped like other skilled personal service providers. 20% is baseline; go higher if you love the work." |
| UC6 | Movers, 4-hour job, 3 movers | Manual total ($800) + "movers, 3 people, 4 hours" | "Tip $40-60 per mover ($120-180 total). Movers are tipped per person. $50/person for a standard 4-hour job is the sweet spot." |

---

## 5. User Experience and Core Flow

### 5.1 App Launch

The app opens directly to the camera viewfinder. No splash screen, no onboarding carousel on repeat launches. First launch only: a single screen explaining the concept in two sentences, a privacy notice ("Your photos and tips never leave this device"), and a "Get Started" button.

### 5.2 Primary Flow: Photo of Bill

```
[Camera Viewfinder]
        |
        v
  [Capture / Select from Library]
        |
        v
  [OCR Processing -- < 2s target]
        |
        v
  [Confirmation Screen]
   - Detected total displayed large
   - "Edit" button if OCR is wrong
   - Tax line shown if detected (informational)
   - Pre-tax subtotal shown if detected (used for calculation)
        |
        v
  [Context Screen]
   - Service type picker (required): Restaurant, Bar/Pub, Cafe/Counter,
     Delivery, Rideshare, Salon/Barber, Spa/Massage, Tattoo, Valet,
     Hotel Housekeeping, Movers, Other
   - Optional context chips (multi-select):
     "Business dinner" | "Date night" | "Holiday season" |
     "Large group (6+)" | "Outstanding service" | "Poor service" |
     "Takeout" | "Buffet"
   - Optional free-text field: "Anything else?" (e.g., "it's raining,"
     "they stayed open late for us," "first time at this barber")
        |
        v
  [Loading -- Claude API call, < 3s target]
        |
        v
  [Recommendation Screen]
   - Primary recommendation: dollar amount + percentage, large and central
   - Two alternates: a lower option ("Acceptable") and a higher option ("Generous")
   - Warm, 1-3 sentence explanation of why this amount is right
   - "Total with tip" shown
   - "Split by N" stepper to divide total+tip by number of people
   - "Copy amount" button for easy entry into payment terminal
   - Optional post-tip feedback: "Too low / Just right / Too high" (single tap, no friction)
```

### 5.3 Secondary Flow: Manual Entry

Accessible via a "No bill? Enter amount" link below the camera viewfinder.

```
[Manual Entry Screen]
   - Numeric keypad for total
   - Same service type picker and context chips as photo flow
        |
        v
  [Same Loading + Recommendation screens as photo flow]
```

### 5.4 Tertiary Flow: No-Bill Situations

For situations with no bill at all (holiday tips, movers, etc.), the user selects "No bill -- just need advice" from the manual entry screen. This skips the amount field entirely and routes to a free-text prompt:

```
[Advice Screen]
   - "Describe the situation" text area
   - Placeholder text: "e.g., Holiday tip for my barber,
     I've been going for 2 years, haircut is usually $40"
        |
        v
  [Same Loading + Recommendation screens, but output is a dollar range
   instead of a single amount]
```

### 5.5 Navigation

- **Bottom tab bar with 2 tabs:**
  - **Tip** (camera icon) -- the primary flow described above.
  - **Guide** (book icon) -- a static, editorially written tipping reference organized by category (see Section 6). This is the free content. Available offline.
- **No settings screen in V1.** The app does one thing. Settings bloat is a non-goal.

### 5.6 Discreet Mode

A single tap on the recommendation amount blurs/hides it. Tap again to reveal. This is for users who want to glance at the recommendation under the table without the person across from them seeing a number. The blur state is not persisted.

---

## 6. Functional Requirements

### FR1: Camera and OCR

| ID | Requirement | Details |
|----|-------------|---------|
| FR1.1 | Camera capture | Full-screen viewfinder. Tap to capture. Flash toggle. |
| FR1.2 | Photo library import | "Choose from library" option on camera screen. |
| FR1.3 | OCR engine | Use Apple Vision framework (VNRecognizeTextRequest) for on-device text recognition. No image data sent to network. |
| FR1.4 | Total extraction | Parse OCR output to identify the "Total" or "Amount Due" line. Use heuristics: largest dollar amount on the bill, line labeled "Total," bottom-most dollar figure. |
| FR1.5 | Pre-tax subtotal detection | If a subtotal line is detected, extract it. The recommendation engine uses pre-tax subtotal for percentage calculation (this is the correct American norm). If only total is found, use total and note this in the output. |
| FR1.6 | Tax detection | If tax line detected, show it for informational purposes. |
| FR1.7 | Confidence threshold | If OCR confidence on the total is below 85%, force manual confirmation with the detected value pre-filled and highlighted in yellow. |
| FR1.8 | Supported formats | Standard US restaurant bills (thermal printer receipts), printed checks, tablet POS screenshots. |
| FR1.9 | Image handling | Bill photo is processed in-memory. It is never written to disk, never sent over the network, and is released from memory after OCR completes. |

### FR2: Context Collection

| ID | Requirement | Details |
|----|-------------|---------|
| FR2.1 | Service type picker | Required. Single-select. 12 categories: Restaurant, Bar/Pub, Cafe/Counter, Delivery, Rideshare, Salon/Barber, Spa/Massage, Tattoo, Valet, Hotel Housekeeping, Movers, Other. |
| FR2.2 | Context chips | Optional. Multi-select. 8 options: Business dinner, Date night, Holiday season, Large group (6+), Outstanding service, Poor service, Takeout, Buffet. |
| FR2.3 | Free-text context | Optional. Max 280 characters. Placeholder: "Anything else? (e.g., it's raining, they stayed open late)" |
| FR2.4 | Location | Auto-detected city/state via CoreLocation. Used only to pass city name to Claude for regional context (e.g., NYC vs. rural Oklahoma). No GPS coordinates sent. User can deny location permission; app works without it. |
| FR2.5 | No-bill mode | For situations without a dollar amount. Free-text description only. Output is a dollar range, not a single number. |

### FR3: Recommendation Engine

| ID | Requirement | Details |
|----|-------------|---------|
| FR3.1 | Claude API call | Text-only payload. Send: pre-tax subtotal (or total), service type, context chips, free-text, city/state. Never send the bill image. |
| FR3.2 | Structured response | Claude returns JSON: `{ "recommended_tip_dollars": number, "recommended_tip_percent": number, "lower_option_dollars": number, "lower_option_percent": number, "higher_option_dollars": number, "higher_option_percent": number, "explanation": string, "total_with_tip": number }` |
| FR3.3 | System prompt | Encodes the product philosophy (see Section 7). |
| FR3.4 | Rounding | All dollar amounts rounded to nearest whole dollar. Percentages rounded to nearest integer. |
| FR3.5 | Offline fallback | If Claude API is unreachable (no network, timeout > 5s, error), fall back to local rules engine: 20% for restaurants/bars, 18% for counter/delivery, 15-20% for rideshare, flat $2-5 for valet. Show "Offline estimate" label. No explanation text in offline mode. |
| FR3.6 | Latency target | API round-trip < 3 seconds at p95. Use Claude Haiku for speed. |

### FR4: Output Display

| ID | Requirement | Details |
|----|-------------|---------|
| FR4.1 | Primary recommendation | Large, central: "$73" with "(21%)" beneath it. |
| FR4.2 | Alternates | Two smaller options flanking the primary: left = "Acceptable" (lower), right = "Generous" (higher). Tappable to swap into primary position. |
| FR4.3 | Explanation | 1-3 sentences. Warm, slightly opinionated, occasionally funny. Never preachy. |
| FR4.4 | Total with tip | Shown below explanation. |
| FR4.5 | Split stepper | "+/-" stepper to divide total+tip by N (2-20). Shows per-person amount. Default N=1 (no split). |
| FR4.6 | Copy button | Copies tip dollar amount to clipboard. Subtle haptic feedback on tap. |
| FR4.7 | Discreet mode | Tap amount to blur. Tap again to reveal. |
| FR4.8 | Feedback | Optional single-tap: "Too low / Just right / Too high." Stored locally for future model tuning data. Not transmitted. |

### FR5: Tipping Guide (Static Content)

| ID | Requirement | Details |
|----|-------------|---------|
| FR5.1 | Categories | Same 12 service types as the picker, plus: Hotel Bellhop, Coat Check, Grocery Delivery, Furniture Delivery, Dog Groomer, Tour Guide, Ski Instructor, Photographer, Caterer, DJ/Band, Wedding Vendor, Building Staff (Doorman/Super), Garbage Collector, Mail Carrier, Nanny/Babysitter, House Cleaner, Personal Trainer, Music Teacher. |
| FR5.2 | Content per category | Typical percentage or dollar range. 2-3 sentence explanation of the norm. "When in doubt" fallback. Updated for holiday season norms where applicable. |
| FR5.3 | Availability | Available offline. No API call needed. Bundled with app. |
| FR5.4 | Search | Simple text search across all guide entries. |

---

## 7. Recommendation Logic (Claude + Heuristics)

### 7.1 System Prompt (Core)

The system prompt sent with every Claude API call encodes the product's tipping philosophy. Below is the full prompt:

```
You are the recommendation engine for Tippy, an American tipping calculator.

PHILOSOPHY:
- The tip should never be memorable. It should be generous enough that no one
  at the table would think the tipper is stingy, but not so extravagant that
  the tip becomes the story of the evening.
- The goal is ease. Everyone -- the server, the host, the guests -- should
  feel that everything is taken care of and they can relax.
- 20% is the floor for sit-down restaurants in America. Not the ceiling. The
  floor.
- When in doubt, round up.
- The tip is not a performance. It is not a statement. It is a quiet act of
  social fluency.

INSTRUCTIONS:
- You will receive: a dollar amount (pre-tax subtotal or total), a service
  type, optional context tags, optional free-text context, and optionally a
  city/state.
- Return a JSON object with these exact fields:
  {
    "recommended_tip_dollars": <integer>,
    "recommended_tip_percent": <integer>,
    "lower_option_dollars": <integer>,
    "lower_option_percent": <integer>,
    "higher_option_dollars": <integer>,
    "higher_option_percent": <integer>,
    "explanation": "<string, 1-3 sentences, warm and slightly opinionated>",
    "total_with_tip": <number>
  }
- The recommended option should be what a socially fluent, generous American
  host would tip without thinking twice.
- The lower option should still be acceptable -- never embarrassing.
- The higher option should be genuinely generous but not ostentatious.
- Round all dollar amounts to the nearest whole dollar.
- Round percentages to the nearest integer.
- For no-bill situations (amount is null), return dollar ranges instead:
  "recommended_tip_dollars": "<string like '100-150'>"
- In the explanation, be warm, direct, and occasionally funny. Never preach.
  Never guilt. Never say "it's customary to." Instead, say why this amount
  makes sense for this situation.
- If "Poor service" is flagged, still recommend at least 15% for sit-down
  restaurants. In the explanation, acknowledge the situation but note that
  in America, tips are a significant part of server income regardless of
  service quality. Keep it empathetic, not lecturing.
- Adjust for regional norms if city/state is provided (e.g., NYC tips tend
  higher than national average).
- Adjust for context: holiday season = bump up. Business dinner = round to
  clean numbers. Large group = check if auto-gratuity might already be
  included (mention this in explanation). Outstanding service = bump up
  and say so.

RESPONSE FORMAT:
- Return ONLY the JSON object. No markdown. No preamble.
```

### 7.2 Offline Fallback Rules

When Claude is unreachable, the app uses these hard-coded defaults:

| Service Type | Default % | Notes |
|-------------|-----------|-------|
| Restaurant | 20% | On pre-tax subtotal if available |
| Bar/Pub | 20% | Or $1-2 per drink if tab is small |
| Cafe/Counter | 18% | |
| Delivery | 18% | Minimum $5 |
| Rideshare | 18% | |
| Salon/Barber | 20% | |
| Spa/Massage | 20% | |
| Tattoo | 20% | |
| Valet | flat $5 | |
| Hotel Housekeeping | flat $5/night | |
| Movers | flat $20/person | |
| Other | 20% | |

No explanation text is shown in offline mode. A small "Offline estimate" badge is displayed.

---

## 8. Guidance Output (Tone and Content)

### Tone

- **Warm, not corporate.** Write like a well-traveled friend who happens to know every tipping norm in America.
- **Opinionated, not preachy.** "20% is the floor" is a stance. Own it. Never say "experts recommend" or "it's customary."
- **Occasionally funny.** Not joke-a-minute. More like a dry aside. "They came out in the rain for you" is the vibe.
- **Never guilt.** If someone flags poor service, acknowledge it. Don't lecture. Still recommend a livable tip and explain why briefly.
- **Concise.** 1-3 sentences max. The user is at a table. They need a number and a reason, not an essay.

### Examples

**Restaurant, $142 bill, date night:**
> "Tip $30 (21%). Date night -- you want the tip to be invisible. Thirty bucks on this bill is generous without making a thing of it. Total: $172."

**Rideshare, $23.40, raining:**
> "Tip $6 (26%). Weather bumps it. They drove through the rain for you."

**Holiday, doorman, NYC:**
> "Tip $100-150. Standard holiday range for a NYC doorman. If they handle your packages and always remember your name, lean toward $150."

**Restaurant, $89 bill, poor service:**
> "Tip $14 (16%). Service wasn't great, and that's frustrating. In the US, servers earn most of their income from tips regardless of the shift they had. Sixteen percent says 'I noticed' without being punitive."

---

## 9. Data, Privacy, and Security

| Principle | Implementation |
|-----------|----------------|
| **No images leave the device.** | Bill photos are processed via on-device Apple Vision OCR. The image is held in memory only during processing and never written to disk or transmitted. |
| **No tip history in the cloud.** | All tip history, feedback, and preferences are stored in local-only Core Data / SwiftData. No iCloud sync. No server-side storage. |
| **Minimal API payload.** | The Claude API call contains only: dollar amount, service type, context tags, free-text (max 280 chars), city/state. No PII. No image data. No names. |
| **Location is coarse.** | City and state only, derived from CoreLocation. No GPS coordinates transmitted. Location is optional; app functions without it. |
| **No analytics in V1.** | No third-party analytics SDKs. No crash reporting beyond Apple's default. No telemetry. |
| **No account.** | No sign-up. No login. No email collection. The app works immediately. |
| **API key security.** | Claude API key is not embedded in the app binary. API calls route through a thin relay server that holds the key. The relay is stateless and logs nothing. See Section 13. |

---

## 10. Monetization and Packaging

### Free Tier

- Full access to the **Tipping Guide** (static reference content).
- **3 AI-powered recommendations per day.** After the limit, the app shows the offline fallback calculation with a note: "Upgrade for AI-powered tips with context and explanations."
- Offline fallback is always available regardless of tier.

### Tippy Pro ($2.99/month or $19.99/year)

- **Unlimited AI-powered recommendations.**
- **No other feature gates.** Pro is purely about volume. Every feature in the app works on free; Pro removes the daily cap.

### Design Principles for Monetization

- The free tier must be genuinely useful. Three recommendations per day covers most people most days.
- No ads. Ever. The app is used at dinner tables. Ads would destroy the experience.
- No "premium categories" or content locks on the guide. Information about how to tip should not be paywalled.
- Subscription managed via StoreKit 2. No custom paywall screens beyond a single, clean upgrade prompt when the daily limit is hit.

---

## 11. Analytics and Success Metrics

Since V1 ships with no third-party analytics, metrics are derived from App Store data, optional in-app feedback, and API relay logs (aggregate counts only, no content).

| Metric | Source | Target |
|--------|--------|--------|
| Daily active users | App Store Connect | Track growth |
| Recommendations per user per day | API relay (count only) | Avg > 1.2 |
| "Just right" feedback rate | Local storage (aggregate if user opts into anonymous sharing in future version) | > 80% |
| Free-to-Pro conversion | StoreKit | > 5% of users who hit daily cap |
| App Store rating | App Store | > 4.5 stars |
| Median time from camera to recommendation | Local timing (not transmitted) | < 10 seconds |
| Offline fallback usage rate | Local counter | < 10% of sessions |

---

## 12. Edge Cases and Error Handling

| Scenario | Behavior |
|----------|----------|
| **OCR cannot detect any dollar amount** | Show manual entry screen pre-populated with empty field. Message: "Couldn't read the bill. Enter the total manually." |
| **OCR detects multiple possible totals** | Show the highest amount (most likely the grand total) with a prominent "Edit" button and all detected amounts listed as alternatives the user can tap to select. |
| **Bill is in a foreign currency** | Detect non-USD currency symbols. Show: "Tippy works with US dollars for now. Enter the amount in USD." |
| **Very small bill (< $5)** | Floor the tip recommendation at $1. Explanation: "Even on a tiny tab, a dollar is the minimum." |
| **Very large bill (> $1,000)** | Recommendation still uses standard percentage. Explanation may note: "On a bill this size, the percentage still applies -- don't overthink it." |
| **Claude API timeout (> 5s)** | Fall back to offline rules. Show "Offline estimate" badge. |
| **Claude returns malformed JSON** | Retry once. If still malformed, fall back to offline rules. |
| **Claude returns unreasonable values (e.g., 0% or 200%)** | Clamp to 10%-40% range. Log locally for debugging. Use clamped value. |
| **No network at all** | Offline fallback immediately. No loading spinner. |
| **Camera permission denied** | Show manual entry as primary flow. Prompt to enable camera in Settings with a single, non-nagging banner. |
| **Location permission denied** | Omit city/state from Claude payload. App works fine without it. |
| **User has hit free tier daily limit** | Show offline fallback calculation. Beneath it, show upgrade prompt: "Want the full story? Tippy Pro gives you unlimited AI tips." |
| **Bill photo is blurry or dark** | If OCR confidence is below 50% on all text, prompt retake: "That's a bit blurry. Try again with more light." |

---

## 13. Technical Requirements (iOS)

### Platform

| Spec | Value |
|------|-------|
| Platform | iOS 17+ |
| Language | Swift |
| UI Framework | SwiftUI |
| Min device | iPhone 12 (A14 chip, for performant on-device OCR) |
| Orientation | Portrait only |

### Architecture

```
┌─────────────────────────────────────────────────┐
│                   iOS App                        │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │  Camera   │  │   OCR    │  │  Context UI   │  │
│  │  Module   │──│ (Vision) │──│  (SwiftUI)    │  │
│  └──────────┘  └──────────┘  └───────┬───────┘  │
│                                      │           │
│                              ┌───────▼───────┐   │
│                              │  Tip Engine   │   │
│                              │  (Orchestrator)│  │
│                              └──┬─────────┬──┘   │
│                                 │         │      │
│                    ┌────────────▼──┐  ┌───▼────┐ │
│                    │ Claude Client │  │Offline │ │
│                    │ (via Relay)   │  │Rules   │ │
│                    └──────┬───────┘  └────────┘ │
│                           │                      │
│  ┌────────────────┐       │                      │
│  │  Local Storage  │       │                      │
│  │  (SwiftData)   │       │                      │
│  └────────────────┘       │                      │
└───────────────────────────┼──────────────────────┘
                            │
                    ┌───────▼───────┐
                    │  Relay Server │
                    │  (stateless)  │
                    │  Holds API key│
                    └───────┬───────┘
                            │
                    ┌───────▼───────┐
                    │  Claude API   │
                    │  (Haiku)      │
                    └───────────────┘
```

### Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| **Apple Vision for OCR** | On-device. No network round-trip for OCR. No bill image ever transmitted. Best privacy story. |
| **Claude Haiku** | Fastest Claude model. The recommendation task is well-scoped; Haiku is sufficient. Keeps latency and cost low. |
| **Stateless relay server** | The Claude API key cannot be embedded in the app binary (it would be trivially extracted). A thin relay server (e.g., a single CloudFlare Worker or AWS Lambda) holds the key, forwards the request, and returns the response. It logs nothing. It stores nothing. It authenticates requests via a rotating app-generated token. |
| **SwiftData for local storage** | Modern Apple persistence framework. Local-only by default. Stores: feedback taps, daily recommendation count (for free tier limit), last-used service type. |
| **StoreKit 2 for subscriptions** | Modern API. Handles receipt validation, subscription status, and renewal natively. |
| **No third-party dependencies beyond the relay** | No Firebase. No Amplitude. No Sentry. V1 ships lean. Apple's built-in crash reporting is sufficient. |

### API Contract: App to Relay

**Endpoint:** `POST /v1/recommend`

**Request:**
```json
{
  "amount": 142.00,
  "amount_type": "pre_tax_subtotal",
  "service_type": "restaurant",
  "context_tags": ["date_night"],
  "free_text": "they stayed open late for us",
  "city": "San Francisco",
  "state": "CA",
  "app_token": "rotating-token-here"
}
```

For no-bill situations, `amount` is `null` and `free_text` is required.

**Response:**
```json
{
  "recommended_tip_dollars": 30,
  "recommended_tip_percent": 21,
  "lower_option_dollars": 26,
  "lower_option_percent": 18,
  "higher_option_dollars": 36,
  "higher_option_percent": 25,
  "explanation": "Date night -- you want the tip to be invisible. Thirty bucks on this bill is generous without making a thing of it.",
  "total_with_tip": 172.00
}
```

**Error response:**
```json
{
  "error": "timeout",
  "fallback": true
}
```

On any error, the app uses offline rules.

---

## 14. Risks and Open Questions

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Claude gives bad advice for an unusual situation** | Medium | Clamp outputs to 10-40% range. Optional user feedback loop for future fine-tuning. Offline fallback as safety net. |
| **OCR misreads the total** | Medium | Mandatory confirmation screen. Low-confidence detection forces manual edit. |
| **Relay server becomes a bottleneck or cost center** | Low | Relay is stateless and horizontally scalable. Claude Haiku token costs are minimal (~$0.001 per recommendation). |
| **Apple rejects the app for being "too simple"** | Low | The Guide tab provides substantial standalone content. The app has clear utility. |
| **User expects the app to work internationally** | Medium | Clear "US tipping norms" language in App Store listing and onboarding. International support is a planned V2 feature. |
| **Tipping culture changes or becomes politically charged** | Low | The app's philosophy ("generous, not memorable") is durable across most cultural shifts. The system prompt is easily updated. |

### Open Questions

| # | Question | Owner | Status |
|---|----------|-------|--------|
| OQ1 | Should the free tier limit be 3/day or 5/day? Needs user testing. | Product | Open |
| OQ2 | Should the relay server be CloudFlare Worker or AWS Lambda? Depends on team familiarity. | Engineering | Open |
| OQ3 | Should we include a "tip jar" for Tippy itself? (Ironic and potentially charming.) | Product | Open |
| OQ4 | What is the right behavior when auto-gratuity is detected on the bill? | Product | Open |
| OQ5 | Should V1 include a widget for quick manual-entry tips from the home screen? | Engineering | Open |
| OQ6 | How do we handle the Tipping Guide editorial process? Who writes/reviews it? | Content | Open |
| OQ7 | Should the "Poor service" context tag exist at all, or does it create a permission structure to under-tip? | Product | Open |

import Foundation

struct GuideEntry: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let range: String
    let tags: [String]
    let text: String
    let fallback: String
}

struct GuideData {
    static let entries: [GuideEntry] = [
        GuideEntry(
            iconName: "restaurant", title: "Restaurant", range: "18–22%",
            tags: ["restaurant", "dining", "dinner", "lunch"],
            text: "20% is the floor for sit-down dining in America. Not the ceiling — the floor. For exceptional service, 22–25% is how you say \"thank you\" without a speech.",
            fallback: "When in doubt: 20%"
        ),
        GuideEntry(
            iconName: "bar", title: "Bar / Pub", range: "20% or $1–2/drink",
            tags: ["bar", "pub", "drinks", "cocktail", "bartender"],
            text: "Running a tab? 20% at close. Paying per drink? $1 for a beer or wine, $2 for a cocktail. Your bartender remembers who tips well — and who doesn't.",
            fallback: "When in doubt: $2 per drink"
        ),
        GuideEntry(
            iconName: "cafe", title: "Cafe / Counter Service", range: "15–20%",
            tags: ["coffee", "cafe", "counter", "bakery"],
            text: "Counter service tips are smaller in absolute dollars but the percentages run a bit higher. A dollar or two on a coffee order is solid. No one expects 20% on a $4 latte, but it's nice.",
            fallback: "When in doubt: $1–2"
        ),
        GuideEntry(
            iconName: "delivery", title: "Food Delivery", range: "18–20%, min $5",
            tags: ["delivery", "food delivery", "doordash", "uber eats", "grubhub"],
            text: "They drove to the restaurant, waited for your food, and brought it to your door. $5 is the floor regardless of order size. 18–20% on larger orders.",
            fallback: "When in doubt: $5 minimum"
        ),
        GuideEntry(
            iconName: "rideshare", title: "Rideshare", range: "15–20%",
            tags: ["rideshare", "uber", "lyft", "taxi", "cab"],
            text: "Rideshare drivers don't see your tip until after they rate you, so the tip is purely about doing right. 15–20% is standard. Bump it up for bad weather, heavy traffic, or help with luggage.",
            fallback: "When in doubt: 18%"
        ),
        GuideEntry(
            iconName: "salon", title: "Salon / Barber", range: "18–25%",
            tags: ["salon", "barber", "haircut", "hair", "color", "stylist"],
            text: "20% is standard for haircuts and styling. For color work or anything over an hour, lean toward 25%. This is skilled, personal work — tip accordingly.",
            fallback: "When in doubt: 20%"
        ),
        GuideEntry(
            iconName: "spa", title: "Spa / Massage", range: "18–25%",
            tags: ["spa", "massage", "facial", "wellness", "nail", "manicure", "pedicure"],
            text: "20% is standard. Check if gratuity is included in the session price — some spas build it in. If not, 20% for standard service, 25% if they worked out that knot in your shoulder.",
            fallback: "When in doubt: 20%"
        ),
        GuideEntry(
            iconName: "tattoo", title: "Tattoo Artist", range: "20–25%",
            tags: ["tattoo", "tattoo artist", "ink", "piercing"],
            text: "Tattoo artists are tipped like other skilled personal service providers. 20% is baseline. Go higher if you love the work. On multi-session pieces, tip each session.",
            fallback: "When in doubt: 20%"
        ),
        GuideEntry(
            iconName: "valet", title: "Valet", range: "Flat $3–7",
            tags: ["valet", "parking", "car"],
            text: "$5 is the standard at most places. $3 for a quick lot, $7+ at a high-end venue or if they had to deal with rain. Tip when they return the car, not when you drop it off.",
            fallback: "When in doubt: $5"
        ),
        GuideEntry(
            iconName: "hotel", title: "Hotel Housekeeping", range: "$3–5 per night",
            tags: ["hotel", "housekeeping", "maid", "room", "housekeeper"],
            text: "$5 per night is generous. Leave it daily — different people may clean your room each day. Put it on the pillow or nightstand with a note that says \"Thank you\" so they know it's for them.",
            fallback: "When in doubt: $5/night"
        ),
        GuideEntry(
            iconName: "bellhop", title: "Hotel Bellhop", range: "$2–5 per bag",
            tags: ["bellhop", "bellman", "hotel bags", "luggage help"],
            text: "$2 per bag is standard, $5 per bag at luxury hotels. If they show you the room and explain the amenities, add a few more dollars.",
            fallback: "When in doubt: $2–3 per bag"
        ),
        GuideEntry(
            iconName: "movers", title: "Movers", range: "$20–50 per mover",
            tags: ["movers", "moving", "moving company"],
            text: "$20–50 per mover depending on the job. 4-hour local move? $20–30 each. Full-day move with stairs and a piano? $50 each. Provide cold drinks and lunch — they'll appreciate it.",
            fallback: "When in doubt: $20–30 per mover"
        ),
        GuideEntry(
            iconName: "coat_check", title: "Coat Check", range: "$1–2 per item",
            tags: ["coat check", "coat", "wardrobe"],
            text: "$1–2 per item. Simple. Already handled by the time you leave.",
            fallback: "When in doubt: $2 per coat"
        ),
        GuideEntry(
            iconName: "grocery_delivery", title: "Grocery Delivery", range: "15–20%, min $5",
            tags: ["grocery", "instacart", "grocery delivery"],
            text: "They shopped for you, carried your bags, and brought them to your door. 15–20% of the order total, minimum $5. Bad weather or heavy order? Go higher.",
            fallback: "When in doubt: $5–10"
        ),
        GuideEntry(
            iconName: "furniture_delivery", title: "Furniture Delivery", range: "$10–20 per person",
            tags: ["furniture", "furniture delivery", "appliance"],
            text: "$10–20 per delivery person. If they assembled anything or dealt with stairs, bump it up. This is physically hard work.",
            fallback: "When in doubt: $15 per person"
        ),
        GuideEntry(
            iconName: "dog_groomer", title: "Dog Groomer", range: "15–20%",
            tags: ["dog", "pet", "groomer", "pet grooming", "dog grooming"],
            text: "15–20% of the grooming cost. If your dog is... a handful... lean toward 20%. They dealt with your chaotic pet with patience. That's worth something.",
            fallback: "When in doubt: 20%"
        ),
        GuideEntry(
            iconName: "tour_guide", title: "Tour Guide", range: "15–20%",
            tags: ["tour", "guide", "tour guide", "sightseeing"],
            text: "15–20% of the tour price. For free walking tours, $10–20 per person is appropriate. They're sharing knowledge and keeping you entertained — tip like a teacher.",
            fallback: "When in doubt: $10–20 per person"
        ),
        GuideEntry(
            iconName: "ski_instructor", title: "Ski / Surf Instructor", range: "15–20%",
            tags: ["ski", "surf", "instructor", "lesson", "snowboard"],
            text: "15–20% of the lesson price. Private lessons get the full treatment. Group lessons? $10–20 per person is solid.",
            fallback: "When in doubt: 15–20%"
        ),
        GuideEntry(
            iconName: "photographer", title: "Photographer", range: "Not expected, but appreciated",
            tags: ["photographer", "photo", "photography"],
            text: "Tips aren't standard for photographers who set their own rates. For wedding or event photography, a bonus of $50–200 is a lovely gesture if they went above and beyond.",
            fallback: "When in doubt: not required, but $20–50 is kind"
        ),
        GuideEntry(
            iconName: "caterer", title: "Caterer", range: "15–20% of total",
            tags: ["caterer", "catering", "event food"],
            text: "Check the contract — many caterers include gratuity. If not, 15–20% of the total bill split among the catering staff is appropriate.",
            fallback: "When in doubt: check contract first, then 15–20%"
        ),
        GuideEntry(
            iconName: "dj_band", title: "DJ / Band", range: "$50–150",
            tags: ["dj", "band", "musician", "wedding band", "music"],
            text: "$50–150 depending on the event size and whether they took requests. Wedding DJ? $50–150. Band? $25–50 per musician.",
            fallback: "When in doubt: $50 per performer"
        ),
        GuideEntry(
            iconName: "wedding_vendor", title: "Wedding Vendors", range: "Varies",
            tags: ["wedding", "wedding vendor", "florist", "planner"],
            text: "Wedding planner: $100–500 depending on budget. Florist: not expected. Hair/makeup: 15–20%. Officiant: $50–100. When in doubt, a heartfelt thank-you note goes a very long way.",
            fallback: "When in doubt: heartfelt note + check vendor norms"
        ),
        GuideEntry(
            iconName: "building_staff", title: "Building Staff (Doorman/Super)", range: "$50–150 holiday",
            tags: ["doorman", "super", "superintendent", "building staff", "concierge", "porter"],
            text: "Holiday tips for building staff in major cities: doorman $50–150, super $75–175, concierge $25–75, porter $25–50. NYC buildings often have suggested ranges.",
            fallback: "When in doubt: $75–100 for doorman, $100 for super"
        ),
        GuideEntry(
            iconName: "garbage_collector", title: "Garbage Collector", range: "$20–30 holiday",
            tags: ["garbage", "trash", "sanitation", "waste"],
            text: "$20–30 per collector at the holidays. They come by every week regardless of weather. Cash in an envelope taped to the bin works.",
            fallback: "When in doubt: $20 each"
        ),
        GuideEntry(
            iconName: "mail_carrier", title: "Mail Carrier", range: "$20 gift card",
            tags: ["mail", "postal", "letter carrier", "usps", "mailman"],
            text: "USPS carriers can accept gifts up to $20 in value per occasion. A $20 gift card to a coffee shop or general store is the classic move.",
            fallback: "When in doubt: $20 gift card"
        ),
        GuideEntry(
            iconName: "nanny", title: "Nanny / Babysitter", range: "One week's pay (holiday)",
            tags: ["nanny", "babysitter", "childcare", "au pair"],
            text: "Holiday tip: one week's pay for a regular nanny. Occasional babysitter: $25–50 gift card plus a small gift. This person takes care of your children — the holiday tip should reflect that trust.",
            fallback: "When in doubt: one week's pay or equivalent gift"
        ),
        GuideEntry(
            iconName: "house_cleaner", title: "House Cleaner", range: "One session's cost (holiday)",
            tags: ["cleaner", "house cleaner", "housekeeper", "cleaning service", "maid service"],
            text: "Holiday tip: the cost of one cleaning session. For a regular cleaner, this is the standard. For a cleaning service, $20–50 per person on the team.",
            fallback: "When in doubt: one session's pay"
        ),
        GuideEntry(
            iconName: "personal_trainer", title: "Personal Trainer", range: "One session's cost (holiday)",
            tags: ["trainer", "personal trainer", "gym", "fitness", "coach"],
            text: "Holiday tip: the cost of one session. Your trainer keeps you accountable — that's worth acknowledging.",
            fallback: "When in doubt: one session's cost"
        ),
        GuideEntry(
            iconName: "music_teacher", title: "Music Teacher", range: "$25–50 (holiday)",
            tags: ["music teacher", "piano teacher", "music lesson", "tutor"],
            text: "Holiday tip: $25–50 or a thoughtful gift. For private instructors, the cost of one lesson is a nice gesture.",
            fallback: "When in doubt: $25–50 or one lesson equivalent"
        ),
    ]
}

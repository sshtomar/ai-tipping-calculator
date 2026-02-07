/* ========================================
   TIPPY — Application Logic
   "The most complicated math in the universe"
   ======================================== */

// ── State ──────────────────────────────
const state = {
    amount: null,
    serviceType: null,
    contextTags: [],
    freeText: '',
    noBillText: '',
    isNoBill: false,
    splitCount: 1,
    selectedOption: 'recommended',
    result: null,
    isDiscreet: false,
};

// ── Loading Messages ───────────────────
const loadingMessages = [
    'Consulting the Bistromathic Drive...',
    'Calculating social fluency...',
    'Crunching the most complicated math in the universe...',
    'Reading the room...',
    'Factoring in the vibes...',
    'Asking a well-traveled friend...',
    'Calibrating generosity...',
    'Solving for "everyone feels good"...',
];

// ── Tip Rules Engine ───────────────────
const BASE_RATES = {
    restaurant: 0.20,
    bar: 0.20,
    cafe: 0.18,
    delivery: 0.18,
    rideshare: 0.18,
    salon: 0.20,
    spa: 0.20,
    tattoo: 0.20,
    valet: null,   // flat
    hotel: null,    // flat
    movers: null,   // flat
    other: 0.20,
};

const FLAT_TIPS = {
    valet: 5,
    hotel: 5,   // per night
    movers: 20, // per person
};

function calculateTipResult() {
    const { amount, serviceType, contextTags, freeText, isNoBill, noBillText } = state;

    if (isNoBill) {
        return calculateNoBillAdvice(noBillText);
    }

    const billAmount = parseFloat(amount);
    if (isNaN(billAmount) || billAmount <= 0) return null;

    // Flat-rate services
    if (FLAT_TIPS[serviceType] !== undefined) {
        return calculateFlatTip(billAmount, serviceType);
    }

    let baseRate = BASE_RATES[serviceType] || 0.20;
    let adjustment = 0;

    // Context adjustments
    if (contextTags.includes('outstanding_service')) adjustment += 0.04;
    if (contextTags.includes('poor_service')) adjustment -= 0.05;
    if (contextTags.includes('holiday_season')) adjustment += 0.03;
    if (contextTags.includes('large_group')) adjustment += 0.02;
    if (contextTags.includes('takeout')) adjustment -= 0.07;
    if (contextTags.includes('buffet')) adjustment -= 0.06;

    // Weather / effort bonus from free text
    const lowerFreeText = freeText.toLowerCase();
    if (lowerFreeText.includes('rain') || lowerFreeText.includes('snow') || lowerFreeText.includes('storm') || lowerFreeText.includes('weather')) {
        adjustment += 0.04;
    }
    if (lowerFreeText.includes('late') || lowerFreeText.includes('stayed open') || lowerFreeText.includes('extra')) {
        adjustment += 0.03;
    }

    let recPct = Math.round((baseRate + adjustment) * 100);

    // Floor: 15% for sit-down even with poor service
    if ((serviceType === 'restaurant' || serviceType === 'bar') && recPct < 15) {
        recPct = 15;
    }

    // Clamp to 10-40%
    recPct = Math.max(10, Math.min(40, recPct));

    const lowerPct = Math.max(10, recPct - 4);
    const higherPct = Math.min(40, recPct + 4);

    const recDollars = Math.round(billAmount * recPct / 100);
    const lowerDollars = Math.round(billAmount * lowerPct / 100);
    const higherDollars = Math.round(billAmount * higherPct / 100);

    // Ensure minimum $1 on small bills
    const finalRec = Math.max(1, recDollars);
    const finalLower = Math.max(1, lowerDollars);
    const finalHigher = Math.max(1, higherDollars);

    // Round for business dinners — use clean numbers
    let adjustedRec = finalRec;
    let adjustedLower = finalLower;
    let adjustedHigher = finalHigher;

    if (contextTags.includes('business_dinner') && billAmount > 100) {
        adjustedRec = Math.round(finalRec / 5) * 5;
        adjustedLower = Math.round(finalLower / 5) * 5;
        adjustedHigher = Math.round(finalHigher / 5) * 5;
    }

    return {
        recommended_tip_dollars: adjustedRec,
        recommended_tip_percent: recPct,
        lower_option_dollars: adjustedLower,
        lower_option_percent: lowerPct,
        higher_option_dollars: adjustedHigher,
        higher_option_percent: higherPct,
        explanation: generateExplanation(billAmount, serviceType, contextTags, freeText, recPct, adjustedRec),
        total_with_tip: billAmount + adjustedRec,
        bill_amount: billAmount,
    };
}

function calculateFlatTip(billAmount, serviceType) {
    const flatAmount = FLAT_TIPS[serviceType];
    const lower = Math.max(1, flatAmount - 2);
    const higher = flatAmount + 3;

    const explanations = {
        valet: `$${flatAmount} is standard for valet. Straightforward — hand it over with the ticket.`,
        hotel: `$${flatAmount} per night is the standard for hotel housekeeping. Leave it on the pillow with a note so they know it's for them.`,
        movers: `$${flatAmount} per mover is the sweet spot. If they handled stairs or heavy furniture, lean higher.`,
    };

    return {
        recommended_tip_dollars: flatAmount,
        recommended_tip_percent: billAmount > 0 ? Math.round(flatAmount / billAmount * 100) : null,
        lower_option_dollars: lower,
        lower_option_percent: billAmount > 0 ? Math.round(lower / billAmount * 100) : null,
        higher_option_dollars: higher,
        higher_option_percent: billAmount > 0 ? Math.round(higher / billAmount * 100) : null,
        explanation: explanations[serviceType] || `$${flatAmount} is the standard flat tip for this service.`,
        total_with_tip: billAmount + flatAmount,
        bill_amount: billAmount,
    };
}

function calculateNoBillAdvice(text) {
    const lower = text.toLowerCase();

    // Try to detect the situation from free text
    let range = '$20–50';
    let explanation = "Without more details, that's a reasonable range for most personal service tips. Adjust up if they go above and beyond.";

    if (lower.includes('barber') || lower.includes('hair')) {
        const priceMatch = lower.match(/\$?(\d+)/);
        const price = priceMatch ? parseInt(priceMatch[1]) : 40;
        if (lower.includes('holiday')) {
            range = `$${price}–${Math.round(price * 1.5)}`;
            explanation = `Holiday tip for your barber: the cost of one visit is the classic move. If you've been going a while, the higher end says "I appreciate you."`;
        } else {
            range = `$${Math.round(price * 0.2)}–${Math.round(price * 0.25)}`;
            explanation = `20–25% of the usual cut price is standard for barbers. They remember who tips well.`;
        }
    } else if (lower.includes('doorman') || lower.includes('building') || lower.includes('super')) {
        if (lower.includes('nyc') || lower.includes('new york') || lower.includes('manhattan')) {
            range = '$100–150';
            explanation = 'Standard holiday range for a NYC doorman. If they handle your packages and always remember your name, lean toward $150.';
        } else {
            range = '$50–100';
            explanation = 'Holiday tip for building staff depends on how much they do for you. $50 is solid; $100 if they go above and beyond.';
        }
    } else if (lower.includes('nanny') || lower.includes('babysit')) {
        range = "One week's pay";
        explanation = "The standard holiday tip for a nanny or regular babysitter is the equivalent of one week's pay. It's a big number, but it reflects the trust involved.";
    } else if (lower.includes('cleaner') || lower.includes('housekeeper') || lower.includes('cleaning')) {
        range = "One session's pay";
        explanation = "Holiday tip for your house cleaner: the cost of one cleaning session is standard. They take care of your space — this says you notice.";
    } else if (lower.includes('mail') || lower.includes('postal') || lower.includes('carrier')) {
        range = '$20–25';
        explanation = 'USPS carriers can accept gifts up to $20 in value per occasion. A gift card to a coffee shop is the classic move.';
    } else if (lower.includes('garbage') || lower.includes('trash') || lower.includes('sanitation')) {
        range = '$20–30';
        explanation = 'Holiday tip for garbage collectors: $20–30 each is the norm. Cash in an envelope taped to the bin works great.';
    } else if (lower.includes('teacher') || lower.includes('tutor') || lower.includes('music lesson')) {
        range = '$25–50';
        explanation = "A gift card or cash in the $25–50 range is a thoughtful holiday gesture for a teacher or tutor. It doesn't have to be huge — it's the thought.";
    } else if (lower.includes('trainer') || lower.includes('gym') || lower.includes('fitness')) {
        range = "One session's cost";
        explanation = "Holiday tip for a personal trainer: the cost of one session is standard. They keep you accountable — return the favor.";
    } else if (lower.includes('dog') || lower.includes('pet') || lower.includes('groomer')) {
        range = "One session's cost";
        explanation = "Holiday tip for a pet groomer or dog walker: one session's cost. They deal with your pet's chaos with a smile.";
    }

    return {
        recommended_tip_dollars: range,
        recommended_tip_percent: null,
        lower_option_dollars: null,
        lower_option_percent: null,
        higher_option_dollars: null,
        higher_option_percent: null,
        explanation: explanation,
        total_with_tip: null,
        bill_amount: null,
        isRange: true,
    };
}

function generateExplanation(amount, serviceType, tags, freeText, pct, tipDollars) {
    const lowerFT = freeText.toLowerCase();
    const parts = [];

    // Service-specific openers
    if (serviceType === 'restaurant' && tags.includes('date_night')) {
        parts.push(`Date night — you want the tip to be invisible. $${tipDollars} on a $${amount.toFixed(0)} bill is generous without making a thing of it.`);
    } else if (serviceType === 'restaurant' && tags.includes('business_dinner')) {
        parts.push(`Business dinner — the tip should be a non-event. $${tipDollars} keeps it clean and professional.`);
    } else if (serviceType === 'restaurant' && tags.includes('poor_service')) {
        parts.push(`Service wasn't great, and that's frustrating. In the US, servers earn most of their income from tips regardless of the shift they had. ${pct}% says "I noticed" without being punitive.`);
    } else if (serviceType === 'restaurant' && tags.includes('outstanding_service')) {
        parts.push(`Outstanding service deserves to be recognized. $${tipDollars} says "we noticed and we appreciate you."`);
    } else if (serviceType === 'restaurant' && tags.includes('large_group')) {
        parts.push(`Large group — double-check the bill for auto-gratuity before adding more. If there's none, $${tipDollars} (${pct}%) handles it. Serving big tables is a workout.`);
    } else if (serviceType === 'restaurant') {
        parts.push(`$${tipDollars} on this bill is solid — generous without overthinking it.`);
    } else if (serviceType === 'bar') {
        if (amount < 20) {
            parts.push(`On a small bar tab, a couple bucks per drink is the move. $${tipDollars} keeps it friendly.`);
        } else {
            parts.push(`$${tipDollars} (${pct}%) on the bar tab. Your bartender remembers who tips well.`);
        }
    } else if (serviceType === 'cafe') {
        parts.push(`Counter tips run a little higher on percentage because the dollar amounts are small. $${tipDollars} on this is solid.`);
    } else if (serviceType === 'delivery') {
        if (tipDollars < 5) {
            parts.push(`Even on a small order, $5 is the floor for delivery. They brought it to your door.`);
            return parts.join(' ');
        }
        parts.push(`$${tipDollars} for delivery is right. They brought it to your door — that's worth something.`);
    } else if (serviceType === 'rideshare') {
        parts.push(`$${tipDollars} for the ride. Drivers don't see the tip until after they rate you, so this is purely about doing right.`);
    } else if (serviceType === 'salon') {
        parts.push(`$${tipDollars} (${pct}%) for salon/barber is spot on. This is skilled personal service — tip like it.`);
    } else if (serviceType === 'spa') {
        parts.push(`$${tipDollars} (${pct}%) for spa or massage. Standard, generous, and well-earned.`);
    } else if (serviceType === 'tattoo') {
        parts.push(`$${tipDollars} (${pct}%) for your artist. Tattoo artists are tipped like other skilled personal service providers. If you love the work, this says so.`);
    } else {
        parts.push(`$${tipDollars} (${pct}%) is the right call here. Generous without going overboard.`);
    }

    // Weather addon
    if (lowerFT.includes('rain') || lowerFT.includes('snow') || lowerFT.includes('storm')) {
        parts.push(`Weather bumps it — they came out in the rain for you.`);
    }

    // Holiday addon
    if (tags.includes('holiday_season') && !parts[0].includes('holiday')) {
        parts.push(`Holiday season means rounding up. 'Tis the season to be generous.`);
    }

    // Takeout note
    if (tags.includes('takeout')) {
        parts.push(`For takeout, a lighter tip is fine — no table service involved.`);
    }

    // Big bill note
    if (amount > 1000) {
        parts.push(`On a bill this size, the percentage still applies — don't overthink it.`);
    }

    return parts.join(' ');
}

// ── Guide Data ─────────────────────────
const guideData = [
    { emoji: '🍽️', title: 'Restaurant', range: '18–22%', tags: ['restaurant', 'dining', 'dinner', 'lunch'],
        text: '20% is the floor for sit-down dining in America. Not the ceiling — the floor. For exceptional service, 22–25% is how you say "thank you" without a speech.',
        fallback: 'When in doubt: 20%' },
    { emoji: '🍸', title: 'Bar / Pub', range: '20% or $1–2/drink', tags: ['bar', 'pub', 'drinks', 'cocktail', 'bartender'],
        text: 'Running a tab? 20% at close. Paying per drink? $1 for a beer or wine, $2 for a cocktail. Your bartender remembers who tips well — and who doesn\'t.',
        fallback: 'When in doubt: $2 per drink' },
    { emoji: '☕', title: 'Cafe / Counter Service', range: '15–20%', tags: ['coffee', 'cafe', 'counter', 'bakery'],
        text: 'Counter service tips are smaller in absolute dollars but the percentages run a bit higher. A dollar or two on a coffee order is solid. No one expects 20% on a $4 latte, but it\'s nice.',
        fallback: 'When in doubt: $1–2' },
    { emoji: '📦', title: 'Food Delivery', range: '18–20%, min $5', tags: ['delivery', 'food delivery', 'doordash', 'uber eats', 'grubhub'],
        text: 'They drove to the restaurant, waited for your food, and brought it to your door. $5 is the floor regardless of order size. 18–20% on larger orders.',
        fallback: 'When in doubt: $5 minimum' },
    { emoji: '🚗', title: 'Rideshare', range: '15–20%', tags: ['rideshare', 'uber', 'lyft', 'taxi', 'cab'],
        text: 'Rideshare drivers don\'t see your tip until after they rate you, so the tip is purely about doing right. 15–20% is standard. Bump it up for bad weather, heavy traffic, or help with luggage.',
        fallback: 'When in doubt: 18%' },
    { emoji: '💇', title: 'Salon / Barber', range: '18–25%', tags: ['salon', 'barber', 'haircut', 'hair', 'color', 'stylist'],
        text: '20% is standard for haircuts and styling. For color work or anything over an hour, lean toward 25%. This is skilled, personal work — tip accordingly.',
        fallback: 'When in doubt: 20%' },
    { emoji: '💆', title: 'Spa / Massage', range: '18–25%', tags: ['spa', 'massage', 'facial', 'wellness', 'nail', 'manicure', 'pedicure'],
        text: '20% is standard. Check if gratuity is included in the session price — some spas build it in. If not, 20% for standard service, 25% if they worked out that knot in your shoulder.',
        fallback: 'When in doubt: 20%' },
    { emoji: '🎨', title: 'Tattoo Artist', range: '20–25%', tags: ['tattoo', 'tattoo artist', 'ink', 'piercing'],
        text: 'Tattoo artists are tipped like other skilled personal service providers. 20% is baseline. Go higher if you love the work. On multi-session pieces, tip each session.',
        fallback: 'When in doubt: 20%' },
    { emoji: '🚙', title: 'Valet', range: 'Flat $3–7', tags: ['valet', 'parking', 'car'],
        text: '$5 is the standard at most places. $3 for a quick lot, $7+ at a high-end venue or if they had to deal with rain. Tip when they return the car, not when you drop it off.',
        fallback: 'When in doubt: $5' },
    { emoji: '🛎️', title: 'Hotel Housekeeping', range: '$3–5 per night', tags: ['hotel', 'housekeeping', 'maid', 'room', 'housekeeper'],
        text: '$5 per night is generous. Leave it daily — different people may clean your room each day. Put it on the pillow or nightstand with a note that says "Thank you" so they know it\'s for them.',
        fallback: 'When in doubt: $5/night' },
    { emoji: '🏨', title: 'Hotel Bellhop', range: '$2–5 per bag', tags: ['bellhop', 'bellman', 'hotel bags', 'luggage help'],
        text: '$2 per bag is standard, $5 per bag at luxury hotels. If they show you the room and explain the amenities, add a few more dollars.',
        fallback: 'When in doubt: $2–3 per bag' },
    { emoji: '📦', title: 'Movers', range: '$20–50 per mover', tags: ['movers', 'moving', 'moving company'],
        text: '$20–50 per mover depending on the job. 4-hour local move? $20–30 each. Full-day move with stairs and a piano? $50 each. Provide cold drinks and lunch — they\'ll appreciate it.',
        fallback: 'When in doubt: $20–30 per mover' },
    { emoji: '🧥', title: 'Coat Check', range: '$1–2 per item', tags: ['coat check', 'coat', 'wardrobe'],
        text: '$1–2 per item. Simple. Already handled by the time you leave.',
        fallback: 'When in doubt: $2 per coat' },
    { emoji: '🛒', title: 'Grocery Delivery', range: '15–20%, min $5', tags: ['grocery', 'instacart', 'grocery delivery'],
        text: 'They shopped for you, carried your bags, and brought them to your door. 15–20% of the order total, minimum $5. Bad weather or heavy order? Go higher.',
        fallback: 'When in doubt: $5–10' },
    { emoji: '🛋️', title: 'Furniture Delivery', range: '$10–20 per person', tags: ['furniture', 'furniture delivery', 'appliance'],
        text: '$10–20 per delivery person. If they assembled anything or dealt with stairs, bump it up. This is physically hard work.',
        fallback: 'When in doubt: $15 per person' },
    { emoji: '🐕', title: 'Dog Groomer', range: '15–20%', tags: ['dog', 'pet', 'groomer', 'pet grooming', 'dog grooming'],
        text: '15–20% of the grooming cost. If your dog is... a handful... lean toward 20%. They dealt with your chaotic pet with patience. That\'s worth something.',
        fallback: 'When in doubt: 20%' },
    { emoji: '🗺️', title: 'Tour Guide', range: '15–20%', tags: ['tour', 'guide', 'tour guide', 'sightseeing'],
        text: '15–20% of the tour price. For free walking tours, $10–20 per person is appropriate. They\'re sharing knowledge and keeping you entertained — tip like a teacher.',
        fallback: 'When in doubt: $10–20 per person' },
    { emoji: '⛷️', title: 'Ski / Surf Instructor', range: '15–20%', tags: ['ski', 'surf', 'instructor', 'lesson', 'snowboard'],
        text: '15–20% of the lesson price. Private lessons get the full treatment. Group lessons? $10–20 per person is solid.',
        fallback: 'When in doubt: 15–20%' },
    { emoji: '📸', title: 'Photographer', range: 'Not expected, but appreciated', tags: ['photographer', 'photo', 'photography'],
        text: 'Tips aren\'t standard for photographers who set their own rates. For wedding or event photography, a bonus of $50–200 is a lovely gesture if they went above and beyond. For mini-sessions or portrait photographers, $20–30 is kind.',
        fallback: 'When in doubt: not required, but $20–50 is kind' },
    { emoji: '🍳', title: 'Caterer', range: '15–20% of total', tags: ['caterer', 'catering', 'event food'],
        text: 'Check the contract — many caterers include gratuity. If not, 15–20% of the total bill split among the catering staff is appropriate.',
        fallback: 'When in doubt: check contract first, then 15–20%' },
    { emoji: '🎵', title: 'DJ / Band', range: '$50–150', tags: ['dj', 'band', 'musician', 'wedding band', 'music'],
        text: '$50–150 depending on the event size and whether they took requests. Wedding DJ? $50–150. Band? $25–50 per musician. If they learned a special song for your first dance, that deserves the higher end.',
        fallback: 'When in doubt: $50 per performer' },
    { emoji: '💒', title: 'Wedding Vendors', range: 'Varies', tags: ['wedding', 'wedding vendor', 'florist', 'planner'],
        text: 'Wedding planner: $100–500 depending on budget. Florist: not expected. Hair/makeup: 15–20%. Officiant: $50–100. When in doubt, a heartfelt thank-you note goes a very long way.',
        fallback: 'When in doubt: heartfelt note + check vendor norms' },
    { emoji: '🏢', title: 'Building Staff (Doorman/Super)', range: '$50–150 holiday', tags: ['doorman', 'super', 'superintendent', 'building staff', 'concierge', 'porter'],
        text: 'Holiday tips for building staff in major cities: doorman $50–150, super $75–175, concierge $25–75, porter $25–50. NYC buildings often have suggested ranges. Length of residency and how much they help you matters.',
        fallback: 'When in doubt: $75–100 for doorman, $100 for super' },
    { emoji: '🗑️', title: 'Garbage Collector', range: '$20–30 holiday', tags: ['garbage', 'trash', 'sanitation', 'waste'],
        text: '$20–30 per collector at the holidays. They come by every week regardless of weather. Cash in an envelope taped to the bin works. Baked goods are also always appreciated.',
        fallback: 'When in doubt: $20 each' },
    { emoji: '📬', title: 'Mail Carrier', range: '$20 gift card', tags: ['mail', 'postal', 'letter carrier', 'usps', 'mailman'],
        text: 'USPS carriers can accept gifts up to $20 in value per occasion. A $20 gift card to a coffee shop or general store is the classic move. Cash over $20 is technically against postal regulations.',
        fallback: 'When in doubt: $20 gift card' },
    { emoji: '👶', title: 'Nanny / Babysitter', range: "One week's pay (holiday)", tags: ['nanny', 'babysitter', 'childcare', 'au pair'],
        text: "Holiday tip: one week's pay for a regular nanny. Occasional babysitter: $25–50 gift card plus a small gift. This person takes care of your children — the holiday tip should reflect that trust.",
        fallback: "When in doubt: one week's pay or equivalent gift" },
    { emoji: '🧹', title: 'House Cleaner', range: "One session's cost (holiday)", tags: ['cleaner', 'house cleaner', 'housekeeper', 'cleaning service', 'maid service'],
        text: "Holiday tip: the cost of one cleaning session. For a regular cleaner, this is the standard. For a cleaning service, $20–50 per person on the team. They take care of your space when you're not looking.",
        fallback: "When in doubt: one session's pay" },
    { emoji: '💪', title: 'Personal Trainer', range: "One session's cost (holiday)", tags: ['trainer', 'personal trainer', 'gym', 'fitness', 'coach'],
        text: "Holiday tip: the cost of one session. Your trainer keeps you accountable — that's worth acknowledging. For regular sessions throughout the year, tips aren't expected beyond the holiday.",
        fallback: "When in doubt: one session's cost" },
    { emoji: '🎹', title: 'Music Teacher', range: '$25–50 (holiday)', tags: ['music teacher', 'piano teacher', 'music lesson', 'tutor'],
        text: "Holiday tip: $25–50 or a thoughtful gift. For private instructors, the cost of one lesson is a nice gesture. For teachers at a school or studio, $25–50 plus a personal note goes a long way.",
        fallback: 'When in doubt: $25–50 or one lesson equivalent' },
];


// ── DOM References ─────────────────────
const $ = (id) => document.getElementById(id);

const els = {
    onboarding: $('onboarding'),
    mainApp: $('main-app'),
    btnGetStarted: $('btn-get-started'),
    btnScanReceipt: $('btn-scan-receipt'),
    receiptInput: $('receipt-input'),
    scanStatus: $('scan-status'),
    screenEntry: $('screen-entry'),
    screenNoBill: $('screen-no-bill'),
    screenContext: $('screen-context'),
    screenLoading: $('screen-loading'),
    screenResult: $('screen-result'),
    billAmount: $('bill-amount'),
    serviceGrid: $('service-grid'),
    btnToContext: $('btn-to-context'),
    btnNoBill: $('btn-no-bill'),
    btnBackNoBill: $('btn-back-no-bill'),
    noBillText: $('no-bill-text'),
    charCount: $('char-count'),
    btnGetAdvice: $('btn-get-advice'),
    btnBackContext: $('btn-back-context'),
    contextChips: $('context-chips'),
    freeText: $('free-text'),
    btnCalculate: $('btn-calculate'),
    btnSkipContext: $('btn-skip-context'),
    loadingMessage: $('loading-message'),
    optionLower: $('option-lower'),
    optionRecommended: $('option-recommended'),
    optionHigher: $('option-higher'),
    lowerAmount: $('lower-amount'),
    lowerPct: $('lower-pct'),
    recAmount: $('rec-amount'),
    recPct: $('rec-pct'),
    higherAmount: $('higher-amount'),
    higherPct: $('higher-pct'),
    resultExplanation: $('result-explanation'),
    totalWithTip: $('total-with-tip'),
    splitMinus: $('split-minus'),
    splitPlus: $('split-plus'),
    splitCount: $('split-count'),
    splitResult: $('split-result'),
    perPersonAmount: $('per-person-amount'),
    btnCopy: $('btn-copy'),
    copyText: $('copy-text'),
    btnDiscreet: $('btn-discreet'),
    btnStartOver: $('btn-start-over'),
    tabTip: $('tab-tip'),
    tabGuide: $('tab-guide'),
    tabBtnTip: $('tab-btn-tip'),
    tabBtnGuide: $('tab-btn-guide'),
    guideSearch: $('guide-search'),
    guideList: $('guide-list'),
};

// ── Screen Navigation ──────────────────
function showScreen(screenEl, direction) {
    const parent = screenEl.parentElement;
    const current = parent.querySelector('.screen.active');

    if (current && current !== screenEl) {
        current.classList.remove('active', 'slide-back');
    }

    screenEl.classList.remove('slide-back');
    if (direction === 'back') {
        screenEl.classList.add('slide-back');
    }
    screenEl.classList.add('active');
}

// ── Tab Navigation ─────────────────────
function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));

    if (tabName === 'tip') {
        els.tabTip.classList.add('active');
        els.tabBtnTip.classList.add('active');
    } else {
        els.tabGuide.classList.add('active');
        els.tabBtnGuide.classList.add('active');
    }
}

// ── Entry Validation ───────────────────
function validateEntry() {
    const hasAmount = state.amount && parseFloat(state.amount) > 0;
    const hasService = state.serviceType !== null;
    els.btnToContext.disabled = !(hasAmount && hasService);
}

// ── Render Result ──────────────────────
function renderResult(result) {
    state.result = result;
    state.splitCount = 1;
    state.isDiscreet = false;
    state.selectedOption = 'recommended';

    if (result.isRange) {
        // No-bill advice
        els.recAmount.textContent = result.recommended_tip_dollars;
        els.recPct.textContent = '';
        els.optionLower.style.display = 'none';
        els.optionHigher.style.display = 'none';
        els.resultExplanation.textContent = result.explanation;
        els.totalWithTip.parentElement.parentElement.style.display = 'none';
        document.querySelector('.split-section').style.display = 'none';
        document.querySelector('.result-actions').style.display = 'none';
    } else {
        els.optionLower.style.display = '';
        els.optionHigher.style.display = '';
        els.totalWithTip.parentElement.parentElement.style.display = '';
        document.querySelector('.split-section').style.display = '';
        document.querySelector('.result-actions').style.display = '';

        els.lowerAmount.textContent = `$${result.lower_option_dollars}`;
        els.lowerPct.textContent = result.lower_option_percent !== null ? `${result.lower_option_percent}%` : '';
        els.recAmount.textContent = `$${result.recommended_tip_dollars}`;
        els.recPct.textContent = result.recommended_tip_percent !== null ? `${result.recommended_tip_percent}%` : '';
        els.higherAmount.textContent = `$${result.higher_option_dollars}`;
        els.higherPct.textContent = result.higher_option_percent !== null ? `${result.higher_option_percent}%` : '';
        els.resultExplanation.textContent = result.explanation;
        els.totalWithTip.textContent = `$${result.total_with_tip.toFixed(2)}`;
    }

    els.splitCount.textContent = '1';
    els.splitResult.classList.add('hidden');

    // Reset feedback
    document.querySelectorAll('.feedback-btn').forEach(b => b.classList.remove('selected'));

    // Reset discreet
    document.querySelector('.result-top').classList.remove('discreet');

    // Reset option selection
    updateOptionSelection('recommended');
}

function updateOptionSelection(option) {
    state.selectedOption = option;
    const result = state.result;
    if (!result || result.isRange) return;

    els.optionLower.classList.toggle('active', option === 'lower');
    els.optionRecommended.classList.toggle('active', option === 'recommended');
    els.optionHigher.classList.toggle('active', option === 'higher');

    // Update total based on selection
    let tipAmount;
    if (option === 'lower') tipAmount = result.lower_option_dollars;
    else if (option === 'higher') tipAmount = result.higher_option_dollars;
    else tipAmount = result.recommended_tip_dollars;

    const total = result.bill_amount + tipAmount;
    els.totalWithTip.textContent = `$${total.toFixed(2)}`;

    updateSplit(total);
}

function updateSplit(total) {
    if (!total) return;
    if (state.splitCount > 1) {
        const perPerson = total / state.splitCount;
        els.perPersonAmount.textContent = `$${perPerson.toFixed(2)}`;
        els.splitResult.classList.remove('hidden');
    } else {
        els.splitResult.classList.add('hidden');
    }
}

function getCurrentTotal() {
    const result = state.result;
    if (!result || result.isRange) return 0;

    let tipAmount;
    if (state.selectedOption === 'lower') tipAmount = result.lower_option_dollars;
    else if (state.selectedOption === 'higher') tipAmount = result.higher_option_dollars;
    else tipAmount = result.recommended_tip_dollars;

    return result.bill_amount + tipAmount;
}

function getCurrentTip() {
    const result = state.result;
    if (!result || result.isRange) return 0;

    if (state.selectedOption === 'lower') return result.lower_option_dollars;
    if (state.selectedOption === 'higher') return result.higher_option_dollars;
    return result.recommended_tip_dollars;
}

// ── Guide Rendering ────────────────────
function renderGuide(filter) {
    const search = (filter || '').toLowerCase().trim();
    const filtered = search
        ? guideData.filter(item =>
            item.title.toLowerCase().includes(search) ||
            item.tags.some(t => t.includes(search)) ||
            item.text.toLowerCase().includes(search)
        )
        : guideData;

    if (filtered.length === 0) {
        els.guideList.innerHTML = '<div class="guide-empty">No results. Try a different search term.</div>';
        return;
    }

    els.guideList.innerHTML = filtered.map((item, i) => `
        <div class="guide-card" data-index="${i}">
            <div class="guide-card-header" onclick="toggleGuideCard(this)">
                <span class="guide-card-emoji">${item.emoji}</span>
                <div class="guide-card-info">
                    <div class="guide-card-title">${item.title}</div>
                    <div class="guide-card-range">${item.range}</div>
                </div>
                <svg class="guide-card-chevron" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </div>
            <div class="guide-card-body">
                <p>${item.text}</p>
                <div class="guide-card-fallback">${item.fallback}</div>
            </div>
        </div>
    `).join('');
}

function toggleGuideCard(header) {
    const card = header.closest('.guide-card');
    card.classList.toggle('open');
}

// ── Reset ──────────────────────────────
function resetCalculator() {
    state.amount = null;
    state.serviceType = null;
    state.contextTags = [];
    state.freeText = '';
    state.noBillText = '';
    state.isNoBill = false;
    state.splitCount = 1;
    state.selectedOption = 'recommended';
    state.result = null;
    state.isDiscreet = false;

    els.billAmount.value = '';
    els.freeText.value = '';
    els.noBillText.value = '';
    els.charCount.textContent = '0';
    els.btnToContext.disabled = true;

    document.querySelectorAll('.service-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));

    showScreen(els.screenEntry, 'back');
}

// ── Event Listeners ────────────────────
function initEvents() {
    // Onboarding
    els.btnGetStarted.addEventListener('click', () => {
        els.onboarding.classList.add('hidden');
        els.mainApp.classList.remove('hidden');
        localStorage.setItem('tippy_onboarded', 'true');
    });

    // Scan receipt
    els.btnScanReceipt.addEventListener('click', () => {
        els.receiptInput.click();
    });

    els.receiptInput.addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        // Show loading state
        els.btnScanReceipt.classList.add('hidden');
        els.scanStatus.classList.remove('hidden');

        try {
            const base64 = await fileToBase64(file);
            const mediaType = file.type || 'image/jpeg';
            const resp = await fetch('/api/analyze-receipt', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ image: base64, mediaType }),
            });

            if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
            const data = await resp.json();

            if (data.error) throw new Error(data.error);

            // Fill in amount
            if (data.total && data.total > 0) {
                const formatted = data.total % 1 === 0
                    ? data.total.toFixed(0)
                    : data.total.toFixed(2);
                els.billAmount.value = formatted;
                state.amount = formatted;
            }

            // Auto-select service type
            if (data.serviceType) {
                const btn = document.querySelector(`.service-btn[data-type="${data.serviceType}"]`);
                if (btn) {
                    document.querySelectorAll('.service-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    state.serviceType = data.serviceType;
                }
            } else if (!state.serviceType) {
                const btn = document.querySelector('.service-btn[data-type="restaurant"]');
                if (btn) {
                    document.querySelectorAll('.service-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    state.serviceType = 'restaurant';
                }
            }

            // Auto-tag large group if 6+ guests
            if (data.numberOfGuests && data.numberOfGuests >= 6) {
                const chip = document.querySelector('.chip[data-tag="large_group"]');
                if (chip && !state.contextTags.includes('large_group')) {
                    chip.classList.add('active');
                    state.contextTags.push('large_group');
                }
            }

            // Show venue name if detected
            if (data.venueName) {
                const hint = document.querySelector('.amount-hint');
                if (hint) hint.textContent = `Scanned from ${data.venueName}`;
            }

            validateEntry();
        } catch (err) {
            console.error('Receipt scan failed:', err);
            // Show a brief inline error, then restore button
            els.scanStatus.querySelector('span').textContent = 'Scan failed — try entering manually';
            setTimeout(() => {
                els.scanStatus.querySelector('span').textContent = 'Analyzing receipt...';
            }, 2500);
        } finally {
            els.btnScanReceipt.classList.remove('hidden');
            els.scanStatus.classList.add('hidden');
            els.receiptInput.value = '';
        }
    });

    // Bill amount input
    els.billAmount.addEventListener('input', (e) => {
        // Allow only numbers and one decimal point
        let val = e.target.value.replace(/[^0-9.]/g, '');
        const parts = val.split('.');
        if (parts.length > 2) val = parts[0] + '.' + parts.slice(1).join('');
        if (parts[1] && parts[1].length > 2) val = parts[0] + '.' + parts[1].slice(0, 2);
        e.target.value = val;
        state.amount = val;
        validateEntry();
    });

    // Service type selection
    els.serviceGrid.addEventListener('click', (e) => {
        const btn = e.target.closest('.service-btn');
        if (!btn) return;

        document.querySelectorAll('.service-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.serviceType = btn.dataset.type;
        validateEntry();
    });

    // Navigate to context
    els.btnToContext.addEventListener('click', () => {
        state.isNoBill = false;
        showScreen(els.screenContext);
    });

    // No bill flow
    els.btnNoBill.addEventListener('click', () => {
        showScreen(els.screenNoBill);
    });

    els.btnBackNoBill.addEventListener('click', () => {
        showScreen(els.screenEntry, 'back');
    });

    els.noBillText.addEventListener('input', (e) => {
        state.noBillText = e.target.value;
        els.charCount.textContent = e.target.value.length;
        els.btnGetAdvice.disabled = e.target.value.trim().length < 10;
    });

    els.btnGetAdvice.addEventListener('click', () => {
        state.isNoBill = true;
        doCalculation();
    });

    // Context screen
    els.btnBackContext.addEventListener('click', () => {
        showScreen(els.screenEntry, 'back');
    });

    // Context chips
    els.contextChips.addEventListener('click', (e) => {
        const chip = e.target.closest('.chip');
        if (!chip) return;

        chip.classList.toggle('active');
        const tag = chip.dataset.tag;
        if (state.contextTags.includes(tag)) {
            state.contextTags = state.contextTags.filter(t => t !== tag);
        } else {
            state.contextTags.push(tag);
        }
    });

    els.freeText.addEventListener('input', (e) => {
        state.freeText = e.target.value;
    });

    // Calculate
    els.btnCalculate.addEventListener('click', doCalculation);
    els.btnSkipContext.addEventListener('click', doCalculation);

    // Result options
    els.optionLower.addEventListener('click', () => updateOptionSelection('lower'));
    els.optionRecommended.addEventListener('click', () => updateOptionSelection('recommended'));
    els.optionHigher.addEventListener('click', () => updateOptionSelection('higher'));

    // Split stepper
    els.splitMinus.addEventListener('click', () => {
        if (state.splitCount > 1) {
            state.splitCount--;
            els.splitCount.textContent = state.splitCount;
            updateSplit(getCurrentTotal());
        }
    });

    els.splitPlus.addEventListener('click', () => {
        if (state.splitCount < 20) {
            state.splitCount++;
            els.splitCount.textContent = state.splitCount;
            updateSplit(getCurrentTotal());
        }
    });

    // Copy
    els.btnCopy.addEventListener('click', () => {
        const tip = getCurrentTip();
        navigator.clipboard.writeText(tip.toString()).then(() => {
            els.copyText.textContent = 'Copied!';
            els.btnCopy.classList.add('copied');
            setTimeout(() => {
                els.copyText.textContent = 'Copy amount';
                els.btnCopy.classList.remove('copied');
            }, 2000);
        });
    });

    // Discreet mode
    els.btnDiscreet.addEventListener('click', () => {
        state.isDiscreet = !state.isDiscreet;
        document.querySelector('.result-top').classList.toggle('discreet', state.isDiscreet);
    });

    // Feedback
    document.querySelectorAll('.feedback-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.feedback-btn').forEach(b => b.classList.remove('selected'));
            btn.classList.add('selected');
            // Store locally
            const feedback = {
                type: btn.dataset.feedback,
                timestamp: Date.now(),
                serviceType: state.serviceType,
            };
            const history = JSON.parse(localStorage.getItem('tippy_feedback') || '[]');
            history.push(feedback);
            localStorage.setItem('tippy_feedback', JSON.stringify(history));
        });
    });

    // Start over
    els.btnStartOver.addEventListener('click', resetCalculator);

    // Tab navigation
    els.tabBtnTip.addEventListener('click', () => switchTab('tip'));
    els.tabBtnGuide.addEventListener('click', () => switchTab('guide'));

    // Guide search
    els.guideSearch.addEventListener('input', (e) => {
        renderGuide(e.target.value);
    });
}

function doCalculation() {
    // Show loading
    showScreen(els.screenLoading);
    els.loadingMessage.textContent = loadingMessages[Math.floor(Math.random() * loadingMessages.length)];

    // Simulate API delay
    const delay = 800 + Math.random() * 800;

    setTimeout(() => {
        // Rotate message mid-loading for fun
        els.loadingMessage.style.opacity = 0;
        setTimeout(() => {
            els.loadingMessage.textContent = loadingMessages[Math.floor(Math.random() * loadingMessages.length)];
            els.loadingMessage.style.opacity = 1;
        }, 200);
    }, delay * 0.5);

    setTimeout(() => {
        const result = calculateTipResult();
        if (result) {
            renderResult(result);
            showScreen(els.screenResult);
        } else {
            // Shouldn't happen, but fallback
            showScreen(els.screenEntry, 'back');
        }
    }, delay);
}

// ── Initialization ─────────────────────
function init() {
    // Check onboarding
    if (localStorage.getItem('tippy_onboarded') === 'true') {
        els.onboarding.classList.add('hidden');
        els.mainApp.classList.remove('hidden');
    }

    // Render guide
    renderGuide();

    // Init events
    initEvents();
}

// Make toggleGuideCard available globally (used in onclick)
window.toggleGuideCard = toggleGuideCard;

// ── Helpers ─────────────────────────────
function fileToBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
            // Strip the data:...;base64, prefix
            const result = reader.result.split(',')[1];
            resolve(result);
        };
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// Go
init();

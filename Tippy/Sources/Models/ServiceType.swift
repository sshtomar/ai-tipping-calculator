import Foundation

enum ServiceType: String, CaseIterable, Identifiable, Codable {
    case restaurant
    case bar
    case cafe
    case delivery
    case rideshare
    case salon
    case spa
    case tattoo
    case valet
    case hotel
    case movers
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .restaurant: "Restaurant"
        case .bar: "Bar / Pub"
        case .cafe: "Cafe / Counter"
        case .delivery: "Delivery"
        case .rideshare: "Rideshare"
        case .salon: "Salon / Barber"
        case .spa: "Spa / Massage"
        case .tattoo: "Tattoo"
        case .valet: "Valet"
        case .hotel: "Hotel Staff"
        case .movers: "Movers"
        case .other: "Other"
        }
    }

    var iconName: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .restaurant: "fork.knife"
        case .bar: "wineglass"
        case .cafe: "cup.and.saucer"
        case .delivery: "shippingbox"
        case .rideshare: "car"
        case .salon: "scissors"
        case .spa: "leaf"
        case .tattoo: "paintbrush.pointed"
        case .valet: "key"
        case .hotel: "bed.double"
        case .movers: "box.truck"
        case .other: "sparkles"
        }
    }

    var tipLabels: (lower: String, recommended: String, higher: String) {
        switch self {
        case .restaurant, .bar:       ("Good", "Great", "Generous")
        case .cafe, .delivery:        ("Standard", "Solid", "Generous")
        case .rideshare:              ("Fair", "Solid", "Generous")
        case .salon, .spa, .tattoo:   ("Respectful", "Generous", "Very Generous")
        default:                      ("Good", "Great", "Generous")
        }
    }

}

enum ContextTag: String, CaseIterable, Identifiable, Codable {
    // Restaurant/bar/cafe
    case businessDinner = "business_dinner"
    case dateNight = "date_night"
    case largeGroup = "large_group"
    case takeout
    case buffet

    // Delivery
    case badWeather = "bad_weather"
    case largeOrder = "large_order"
    case lateNight = "late_night"

    // Rideshare
    case longRide = "long_ride"
    case helpedWithBags = "helped_with_bags"

    // Salon
    case complexStyle = "complex_style"
    case regularClient = "regular_client"

    // Spa / Tattoo
    case longSession = "long_session"
    case complexDesign = "complex_design"

    // Valet / Hotel
    case specialEvent = "special_event"
    case multiNight = "multi_night"
    case extraRequests = "extra_requests"

    // Movers
    case stairs
    case heavyItems = "heavy_items"
    case longMove = "long_move"

    // Universal
    case outstandingService = "outstanding_service"
    case poorService = "poor_service"
    case holidaySeason = "holiday_season"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .businessDinner: "Business dinner"
        case .dateNight: "Date night"
        case .largeGroup: "Large group (6+)"
        case .takeout: "Takeout"
        case .buffet: "Buffet"
        case .badWeather: "Bad weather"
        case .largeOrder: "Large order"
        case .lateNight: "Late night"
        case .longRide: "Long ride"
        case .helpedWithBags: "Helped with bags"
        case .complexStyle: "Complex style"
        case .regularClient: "Regular client"
        case .longSession: "Long session"
        case .complexDesign: "Complex design"
        case .specialEvent: "Special event"
        case .multiNight: "Multi-night stay"
        case .extraRequests: "Extra requests"
        case .stairs: "Stairs involved"
        case .heavyItems: "Heavy / bulky items"
        case .longMove: "Long distance"
        case .outstandingService: "Outstanding service"
        case .poorService: "Poor service"
        case .holidaySeason: "Holiday season"
        }
    }

    var iconName: String {
        switch self {
        case .businessDinner: "briefcase"
        case .dateNight: "heart"
        case .largeGroup: "person.3"
        case .takeout: "bag"
        case .buffet: "fork.knife"
        case .badWeather: "cloud.rain"
        case .largeOrder: "bag.fill"
        case .lateNight: "moon.stars"
        case .longRide: "road.lanes"
        case .helpedWithBags: "suitcase"
        case .complexStyle: "paintpalette"
        case .regularClient: "arrow.triangle.2.circlepath"
        case .longSession: "clock"
        case .complexDesign: "scribble.variable"
        case .specialEvent: "party.popper"
        case .multiNight: "calendar"
        case .extraRequests: "bell"
        case .stairs: "figure.stairs"
        case .heavyItems: "shippingbox.fill"
        case .longMove: "map"
        case .outstandingService: "star"
        case .poorService: "hand.thumbsdown"
        case .holidaySeason: "gift"
        }
    }

    private static let universal: [ContextTag] = [.outstandingService, .poorService, .holidaySeason]

    static func tags(for serviceType: ServiceType) -> [ContextTag] {
        switch serviceType {
        case .restaurant, .bar, .cafe:
            [.businessDinner, .dateNight, .largeGroup, .takeout, .buffet] + universal
        case .delivery:
            [.badWeather, .largeOrder, .lateNight] + universal
        case .rideshare:
            [.badWeather, .lateNight, .longRide, .helpedWithBags] + universal
        case .salon:
            [.complexStyle, .regularClient] + universal
        case .spa:
            [.longSession, .regularClient] + universal
        case .tattoo:
            [.complexDesign, .longSession, .regularClient] + universal
        case .valet:
            [.badWeather, .specialEvent] + universal
        case .hotel:
            [.multiNight, .extraRequests, .specialEvent] + universal
        case .movers:
            [.stairs, .heavyItems, .longMove] + universal
        case .other:
            universal
        }
    }
}

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
}

enum ContextTag: String, CaseIterable, Identifiable, Codable {
    case businessDinner = "business_dinner"
    case dateNight = "date_night"
    case holidaySeason = "holiday_season"
    case largeGroup = "large_group"
    case outstandingService = "outstanding_service"
    case poorService = "poor_service"
    case takeout
    case buffet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .businessDinner: "Business dinner"
        case .dateNight: "Date night"
        case .holidaySeason: "Holiday season"
        case .largeGroup: "Large group (6+)"
        case .outstandingService: "Outstanding service"
        case .poorService: "Poor service"
        case .takeout: "Takeout"
        case .buffet: "Buffet"
        }
    }

    var iconName: String {
        switch self {
        case .businessDinner: "briefcase"
        case .dateNight: "heart"
        case .holidaySeason: "gift"
        case .largeGroup: "person.3"
        case .outstandingService: "star"
        case .poorService: "hand.thumbsdown"
        case .takeout: "bag"
        case .buffet: "fork.knife"
        }
    }
}

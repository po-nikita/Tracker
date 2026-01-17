import Foundation

enum Weekday: Int, Codable, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var title: String {
        NSLocalizedString("weekday.\(key)", comment: "")
    }

    var shortTitle: String {
        NSLocalizedString("weekday.\(key).short", comment: "")
    }

    private var key: String {
        switch self {
        case .monday: return "monday"
        case .tuesday: return "tuesday"
        case .wednesday: return "wednesday"
        case .thursday: return "thursday"
        case .friday: return "friday"
        case .saturday: return "saturday"
        case .sunday: return "sunday"
        }
    }
}

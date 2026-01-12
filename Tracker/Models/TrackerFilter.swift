import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var displayName: String {
        switch self {
        case .all:
            return NSLocalizedString("tracker.filter.all", comment: "")
        case .today:
            return NSLocalizedString("tracker.filter.today", comment: "")
        case .completed:
            return NSLocalizedString("tracker.filter.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("tracker.filter.uncompleted", comment: "")
        }
    }
}

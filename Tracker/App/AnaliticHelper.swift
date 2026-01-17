import YandexMobileMetrica

enum AnalyticsEvent {
    static let event = "event"
    static let screen = "screen"
    static let item = "item"
}

final class AnaliticHelper {

    static func report(event: String, screen: String, item: String? = nil) {
        print("ANALYTICS SEND:", event, screen, item ?? "nil")

        var params: [String: Any] = [
            AnalyticsEvent.event: event,
            AnalyticsEvent.screen: screen
        ]

        if let item {
            params[AnalyticsEvent.item] = item
        }

        YMMYandexMetrica.reportEvent("ui_event", parameters: params, onFailure: nil)
    }
}

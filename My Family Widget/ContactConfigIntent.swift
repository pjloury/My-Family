import AppIntents
import WidgetKit

struct ContactAppEntity: AppEntity {
    let id: String
    let displayName: String

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Contact")
    static var defaultQuery = ContactAppEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayName)")
    }
}

struct ContactAppEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ContactAppEntity] {
        loadAllWidgetContacts()
            .filter { identifiers.contains($0.id.uuidString) }
            .map { ContactAppEntity(id: $0.id.uuidString, displayName: $0.displayName) }
    }

    func suggestedEntities() async throws -> [ContactAppEntity] {
        loadAllWidgetContacts().map {
            ContactAppEntity(id: $0.id.uuidString, displayName: $0.displayName)
        }
    }
}

struct SelectContactIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Contact"
    static var description = IntentDescription("Choose a family member to track.")

    @Parameter(title: "Contact")
    var contact: ContactAppEntity?
}

struct NextPageIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Page"
    static var isDiscoverable = false

    @Parameter(title: "Family")
    var family: String  // "medium" or "large"

    @Parameter(title: "Page Size")
    var pageSize: Int

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: widgetAppGroupID)
        let key = family == "medium" ? mediumPageKey : largePageKey
        let current = defaults?.integer(forKey: key) ?? 1
        let total = loadAllWidgetContacts().count
        let maxPage = max(1, Int(ceil(Double(total) / Double(pageSize))))
        defaults?.set(min(current + 1, maxPage), forKey: key)
        return .result()
    }
}

struct PrevPageIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Page"
    static var isDiscoverable = false

    @Parameter(title: "Family")
    var family: String

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: widgetAppGroupID)
        let key = family == "medium" ? mediumPageKey : largePageKey
        let current = defaults?.integer(forKey: key) ?? 1
        defaults?.set(max(current - 1, 1), forKey: key)
        return .result()
    }
}

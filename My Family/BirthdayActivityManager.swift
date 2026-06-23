import ActivityKit
import Foundation

// BirthdayActivityAttributes must match BirthdayLiveActivity.swift in the widget extension exactly.
struct BirthdayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contactName: String
        var firstName: String
        var birthdayAge: Int
    }

    var contactId: String
}

@available(iOS 16.2, *)
class BirthdayActivityManager {
    static let shared = BirthdayActivityManager()
    private var currentActivity: Activity<BirthdayActivityAttributes>?

    private init() {}

    func startIfBirthday(for contacts: [Contact]) {
        let calendar = Calendar.current
        let today = Date()
        let todayMonth = calendar.component(.month, from: today)
        let todayDay = calendar.component(.day, from: today)

        let birthdayContacts = contacts.filter {
            calendar.component(.month, from: $0.birthday) == todayMonth &&
            calendar.component(.day, from: $0.birthday) == todayDay
        }

        guard let contact = birthdayContacts.first else { return }
        start(for: contact)
    }

    func start(for contact: Contact) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()

        let age = contact.wouldBeAge
        let attrs = BirthdayActivityAttributes(contactId: contact.id.uuidString)
        let state = BirthdayActivityAttributes.ContentState(
            contactName: contact.name,
            firstName: contact.firstName,
            birthdayAge: age
        )

        do {
            currentActivity = try Activity.request(
                attributes: attrs,
                content: .init(state: state, staleDate: Calendar.current.date(byAdding: .hour, value: 16, to: Date()))
            )
            print("Started birthday Live Activity for \(contact.name)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func end() {
        guard let activity = currentActivity else { return }
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("Ended birthday Live Activity")
        }
        currentActivity = nil
    }
}

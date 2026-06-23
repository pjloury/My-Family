import Foundation
import UserNotifications
import SwiftUI

// MARK: - Timing Settings

struct NotificationTimingSettings: Codable {
    var oneMonthBefore: Bool = false
    var oneWeekBefore: Bool = true
    var threeDaysBefore: Bool = false
    var oneDayBefore: Bool = false
    var dayOf: Bool = true

    static let userDefaultsKey = "notificationTimingSettings"

    static func load() -> NotificationTimingSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(NotificationTimingSettings.self, from: data)
        else { return NotificationTimingSettings() }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }

    // The day-offsets this configuration triggers on
    var enabledOffsets: [Int] {
        var offsets: [Int] = []
        if dayOf          { offsets.append(0) }
        if oneDayBefore   { offsets.append(1) }
        if threeDaysBefore { offsets.append(3) }
        if oneWeekBefore  { offsets.append(7) }
        if oneMonthBefore { offsets.append(30) }
        return offsets
    }
}

// MARK: - Manager

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    func scheduleBirthdayNotifications(for contacts: [Contact]) {
        removeAllBirthdayNotifications()

        let settings = NotificationTimingSettings.load()
        let offsets = settings.enabledOffsets
        guard !offsets.isEmpty else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for contact in contacts where contact.notificationsEnabled {
            let nextBirthday = getNextBirthday(for: contact.birthday, calendar: calendar, today: today)

            for offset in offsets {
                guard let fireDate = calendar.date(byAdding: .day, value: -offset, to: nextBirthday) else { continue }
                let fireDayStart = calendar.startOfDay(for: fireDate)
                if fireDayStart >= today {
                    scheduleBirthdayNotification(for: contact, daysUntil: offset, on: fireDate, calendar: calendar)
                }
            }

            // Schedule death anniversary notification if contact is deceased
            if let deceasedDate = contact.deceasedDate {
                scheduleDeathAnniversaryNotification(for: contact, deceasedDate: deceasedDate, calendar: calendar, today: today)
            }
        }
    }

    private func scheduleBirthdayNotification(for contact: Contact, daysUntil: Int, on fireDate: Date, calendar: Calendar) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let isDeceased = contact.isDeceased

        switch daysUntil {
        case 0:
            if isDeceased {
                let age = contact.wouldBeAge
                content.title = "Remembering \(contact.firstName) 🕊"
                content.body = "Today would have been \(contact.firstName)'s \(age)\(ordinalSuffix(age)) birthday."
            } else {
                content.title = "Happy Birthday! 🎂"
                content.body = "Today is \(contact.firstName)'s birthday!"
            }
        case 1:
            content.title = isDeceased ? "Remembering \(contact.firstName) 🕊" : "Birthday Tomorrow 🎁"
            content.body = isDeceased ? "\(contact.firstName)'s birthday would be tomorrow." : "\(contact.firstName)'s birthday is tomorrow!"
        case 3:
            content.title = isDeceased ? "Remembering \(contact.firstName) 🕊" : "Birthday in 3 Days 🎂"
            content.body = isDeceased ? "\(contact.firstName)'s birthday would be in 3 days." : "\(contact.firstName)'s birthday is in 3 days!"
        case 7:
            content.title = isDeceased ? "Remembering \(contact.firstName) 🕊" : "Birthday Next Week 🎂"
            content.body = isDeceased ? "\(contact.firstName)'s birthday would be in 1 week." : "\(contact.firstName)'s birthday is in 1 week!"
        default:
            content.title = isDeceased ? "Remembering \(contact.firstName) 🕊" : "Birthday Next Month 🎂"
            content.body = isDeceased ? "\(contact.firstName)'s birthday would be in about a month." : "\(contact.firstName)'s birthday is in about a month!"
        }

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "BIRTHDAY_REMINDER"
        content.threadIdentifier = "birthday_notifications"
        content.interruptionLevel = .timeSensitive

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: fireDate)
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "birthday_\(contact.id.uuidString)_\(daysUntil)days",
            content: content,
            trigger: trigger
        )
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(contact.name): \(error)")
            } else {
                print("Scheduled \(daysUntil)-day birthday notification for \(contact.name) on \(fireDate)")
            }
        }
    }

    private func scheduleDeathAnniversaryNotification(for contact: Contact, deceasedDate: Date, calendar: Calendar, today: Date) {
        let center = UNUserNotificationCenter.current()

        // Find next anniversary of death
        let currentYear = calendar.component(.year, from: today)
        let deathMonth = calendar.component(.month, from: deceasedDate)
        let deathDay = calendar.component(.day, from: deceasedDate)
        let deathYear = calendar.component(.year, from: deceasedDate)

        var components = DateComponents()
        components.month = deathMonth
        components.day = deathDay
        components.hour = 9
        components.minute = 0

        // Try this year, then next year
        for yearOffset in 0...1 {
            components.year = currentYear + yearOffset
            guard let anniversary = calendar.date(from: components) else { continue }
            let anniversaryStart = calendar.startOfDay(for: anniversary)
            if anniversaryStart >= today {
                let yearsAgo = (currentYear + yearOffset) - deathYear
                let content = UNMutableNotificationContent()
                content.title = "Remembering \(contact.firstName) 🕊"
                content.body = yearsAgo == 1
                    ? "It's been 1 year since \(contact.firstName) passed away."
                    : "It's been \(yearsAgo) years since \(contact.firstName) passed away."
                content.sound = .default
                content.categoryIdentifier = "BIRTHDAY_REMINDER"
                content.threadIdentifier = "birthday_notifications"

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "anniversary_\(contact.id.uuidString)_\(currentYear + yearOffset)",
                    content: content,
                    trigger: trigger
                )
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling anniversary notification for \(contact.name): \(error)")
                    } else {
                        print("Scheduled death anniversary notification for \(contact.name)")
                    }
                }
                break
            }
        }
    }

    private func ordinalSuffix(_ n: Int) -> String {
        let mod100 = n % 100
        if mod100 >= 11 && mod100 <= 13 { return "th" }
        switch n % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    private func getNextBirthday(for birthday: Date, calendar: Calendar, today: Date) -> Date {
        let currentYear = calendar.component(.year, from: today)
        let birthdayMonth = calendar.component(.month, from: birthday)
        let birthdayDay = calendar.component(.day, from: birthday)

        var components = DateComponents()
        components.year = currentYear
        components.month = birthdayMonth
        components.day = birthdayDay

        guard let thisYearBirthday = calendar.date(from: components) else { return birthday }

        if thisYearBirthday < today {
            components.year = currentYear + 1
            return calendar.date(from: components) ?? birthday
        }
        return thisYearBirthday
    }

    func removeAllBirthdayNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests.filter {
                $0.identifier.hasPrefix("birthday_") || $0.identifier.hasPrefix("anniversary_")
            }.map { $0.identifier }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
                print("Removed \(ids.count) birthday/anniversary notifications")
            }
        }
    }

    func checkAndScheduleNotifications(for contactManager: ContactManager) {
        let allContacts = contactManager.contactLists.flatMap { $0.contacts }
        scheduleBirthdayNotifications(for: allContacts)
    }

    // MARK: - Test helpers

    func scheduleTestNotification(for contact: Contact) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            print("Notification auth: \(settings.authorizationStatus.rawValue)")
            DispatchQueue.main.async {
                let content = UNMutableNotificationContent()
                content.title = "Test Birthday Reminder 🎂"
                content.body = "\(contact.firstName)'s birthday is in 1 week! (Test)"
                content.sound = .default
                content.badge = 1
                content.categoryIdentifier = "BIRTHDAY_REMINDER"
                content.threadIdentifier = "birthday_notifications"
                content.interruptionLevel = .timeSensitive
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
                let request = UNNotificationRequest(identifier: "test_birthday_\(contact.id.uuidString)", content: content, trigger: trigger)
                center.add(request) { error in
                    if let error = error { print("❌ Test notification error: \(error)") }
                    else { print("✅ Test notification scheduled for \(contact.name)") }
                }
            }
        }
    }

    func showImmediateTestNotification(for contact: Contact) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Immediate Test"
        content.body = "Immediate notification for \(contact.firstName)!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "BIRTHDAY_REMINDER"
        content.threadIdentifier = "birthday_notifications"
        content.interruptionLevel = .timeSensitive
        let request = UNNotificationRequest(identifier: "immediate_test_\(contact.id.uuidString)", content: content, trigger: nil)
        center.add(request) { error in
            if let error = error { print("❌ Immediate notification error: \(error)") }
            else { print("✅ Immediate notification added for \(contact.name)") }
        }
    }
}

import Foundation

#if DEBUG
enum MockDataLoader {
    static func injectIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        let env = ProcessInfo.processInfo.environment
        guard args.contains("--inject-mock-data") || env["INJECT_MOCK_DATA"] == "1" else { return }

        let lists = buildMockLists()
        if let encoded = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(encoded, forKey: "SavedContactLists")
            UserDefaults(suiteName: "group.pjloury.My-Family")?.set(encoded, forKey: "SavedContactLists")
        }
        UserDefaults.standard.set(0, forKey: "SelectedListIndex")
        // Suppress notification permission modal
        UserDefaults.standard.set(true, forKey: "hasShownNotificationPermissionModal")
    }

    // MARK: – Data

    private static func buildMockLists() -> [ContactList] {
        var family = ContactList(title: "My Family")
        family.contacts = familyContacts()

        var friends = ContactList(title: "Close Friends")
        friends.contacts = friendsContacts()

        return [family, friends]
    }

    private static func familyContacts() -> [Contact] {
        // Birthdays chosen so the list looks lively relative to any launch date.
        // "Today" birthday → Mom (June 27). Others spread across the year.
        [
            Contact(
                name: "Patricia Loury",
                firstName: "Patricia",
                nickname: "Mom",
                birthday: date(month: 6, day: 27, year: 1954),
                photoFileName: nil,
                phoneNumber: "415-555-0101",
                relation: .mother
            ),
            Contact(
                name: "Richard Loury",
                firstName: "Richard",
                nickname: "Dad",
                birthday: date(month: 6, day: 30, year: 1952),
                photoFileName: nil,
                phoneNumber: "415-555-0102",
                relation: .father
            ),
            Contact(
                name: "Emma Loury",
                firstName: "Emma",
                nickname: nil,
                birthday: date(month: 7, day: 11, year: 1990),
                photoFileName: nil,
                phoneNumber: "415-555-0103",
                relation: .sister
            ),
            Contact(
                name: "Sophia Loury",
                firstName: "Sophia",
                nickname: "Sofi",
                birthday: date(month: 8, day: 14, year: 1989),
                photoFileName: nil,
                phoneNumber: "415-555-0104",
                notificationsEnabled: true,
                calendarReminderEnabled: true,
                deceasedDate: nil,
                specialDates: [
                    SpecialDate(
                        date: date(month: 9, day: 3, year: 2016),
                        label: "Wedding Anniversary"
                    )
                ],
                relation: .wife
            ),
            Contact(
                name: "Jake Loury",
                firstName: "Jake",
                nickname: nil,
                birthday: date(month: 9, day: 5, year: 2017),
                photoFileName: nil,
                phoneNumber: nil,
                relation: .son
            ),
            Contact(
                name: "Lily Loury",
                firstName: "Lily",
                nickname: nil,
                birthday: date(month: 3, day: 20, year: 2020),
                photoFileName: nil,
                phoneNumber: nil,
                notificationsEnabled: true,
                calendarReminderEnabled: true,
                deceasedDate: nil,
                specialDates: [
                    SpecialDate(
                        date: date(month: 9, day: 4, year: 2025),
                        label: "First Day of School"
                    )
                ],
                relation: .daughter
            ),
            Contact(
                name: "Rose Gallagher",
                firstName: "Rose",
                nickname: "Grandma Rose",
                birthday: date(month: 10, day: 15, year: 1928),
                photoFileName: nil,
                phoneNumber: nil,
                notificationsEnabled: true,
                calendarReminderEnabled: true,
                deceasedDate: date(month: 3, day: 8, year: 2019),
                specialDates: [],
                relation: .grandmother
            ),
            Contact(
                name: "Arthur Gallagher",
                firstName: "Arthur",
                nickname: "Grandpa Art",
                birthday: date(month: 12, day: 3, year: 1925),
                photoFileName: nil,
                phoneNumber: nil,
                notificationsEnabled: true,
                calendarReminderEnabled: true,
                deceasedDate: date(month: 7, day: 22, year: 2008),
                specialDates: [],
                relation: .grandfather
            ),
            Contact(
                name: "Michael Loury",
                firstName: "Michael",
                nickname: "Uncle Mike",
                birthday: date(month: 11, day: 19, year: 1958),
                photoFileName: nil,
                phoneNumber: "415-555-0107",
                relation: .uncle
            ),
            Contact(
                name: "Claire Nguyen",
                firstName: "Claire",
                nickname: nil,
                birthday: date(month: 2, day: 8, year: 1985),
                photoFileName: nil,
                phoneNumber: "415-555-0108",
                relation: .sisterInLaw
            )
        ]
    }

    private static func friendsContacts() -> [Contact] {
        [
            Contact(
                name: "Sarah Kim",
                firstName: "Sarah",
                nickname: nil,
                birthday: date(month: 7, day: 4, year: 1989),
                photoFileName: nil,
                phoneNumber: "415-555-0201",
                notificationsEnabled: true,
                calendarReminderEnabled: true,
                deceasedDate: nil,
                specialDates: [
                    SpecialDate(
                        date: date(month: 5, day: 12, year: 2010),
                        label: "Friendiversary"
                    )
                ],
                relation: .bestFriend
            ),
            Contact(
                name: "Marcus Johnson",
                firstName: "Marcus",
                nickname: nil,
                birthday: date(month: 4, day: 22, year: 1988),
                photoFileName: nil,
                phoneNumber: "415-555-0202",
                relation: .friend
            ),
            Contact(
                name: "Priya Patel",
                firstName: "Priya",
                nickname: nil,
                birthday: date(month: 1, day: 15, year: 1991),
                photoFileName: nil,
                phoneNumber: "415-555-0203",
                relation: .friend
            ),
            Contact(
                name: "Tom Reyes",
                firstName: "Tom",
                nickname: nil,
                birthday: date(month: 8, day: 30, year: 1986),
                photoFileName: nil,
                phoneNumber: "415-555-0204",
                relation: .friend
            )
        ]
    }

    private static func date(month: Int, day: Int, year: Int) -> Date {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day
        c.hour = 12
        return Calendar.current.date(from: c) ?? Date()
    }
}
#endif

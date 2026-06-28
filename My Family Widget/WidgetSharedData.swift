import Foundation
import SwiftUI
import UIKit

let widgetAppGroupID = "group.pjloury.My-Family"
let widgetContactsKey = "SavedContactLists"
let mediumPageKey = "widgetMediumPage"
let largePageKey = "widgetLargePageKey"

struct WidgetContactData: Decodable, Identifiable {
    let id: UUID
    let name: String
    let firstName: String
    let nickname: String?
    let birthday: Date
    let photoFileName: String?

    // Set after decoding during timeline generation — not from JSON
    var photoImage: UIImage? = nil

    var displayName: String { nickname ?? firstName }

    var daysUntilNextBirthday: Int {
        let calendar = Calendar.current
        let now = Date()
        let todayComps = calendar.dateComponents([.year, .month, .day], from: now)
        let today = calendar.date(from: todayComps) ?? now
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        var next = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? birthday
        if next < today {
            next = calendar.date(from: DateComponents(year: year + 1, month: month, day: day)) ?? birthday
        }
        return calendar.dateComponents([.day], from: today, to: next).day ?? 0
    }

    var birthdayMonthDay: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: birthday)
    }

    var daysLabel: String {
        let days = daysUntilNextBirthday
        if days == 0 { return "Today! 🎂" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }

    // Decodable only reads these fields; photoImage is set separately
    enum CodingKeys: String, CodingKey {
        case id, name, firstName, nickname, birthday, photoFileName
    }
}

// Equatable/Hashable by id only so UIImage doesn't need to conform
extension WidgetContactData: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}
extension WidgetContactData: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

private struct WidgetContactListData: Decodable {
    let contacts: [WidgetContactData]
}

func loadAllWidgetContacts() -> [WidgetContactData] {
    guard let defaults = UserDefaults(suiteName: widgetAppGroupID),
          let data = defaults.data(forKey: widgetContactsKey) else { return [] }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .deferredToDate
    guard let lists = try? decoder.decode([WidgetContactListData].self, from: data) else { return [] }

    var contacts = lists.flatMap { $0.contacts }
        .sorted { $0.daysUntilNextBirthday < $1.daysUntilNextBirthday }

    // Pre-load photos here (during timeline generation, not during rendering)
    if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: widgetAppGroupID) {
        let photosDir = groupURL.appendingPathComponent("ContactPhotos")
        for i in contacts.indices {
            guard let fileName = contacts[i].photoFileName else { continue }
            let fileURL = photosDir.appendingPathComponent(fileName)
            if let data = try? Data(contentsOf: fileURL) {
                contacts[i].photoImage = UIImage(data: data)
            }
        }
    }

    return contacts
}

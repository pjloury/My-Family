import Foundation
import SwiftUI

struct ContactList: Identifiable, Codable {
    let id: UUID
    var title: String
    var contacts: [Contact]
    var selectedSortOption: SortOption
    var sortDirection: SortDirection
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.contacts = []
        self.selectedSortOption = .name
        self.sortDirection = .ascending
    }
    
    // Custom coding keys to handle UUID
    enum CodingKeys: String, CodingKey {
        case id, title, contacts, selectedSortOption, sortDirection
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.contacts = try container.decode([Contact].self, forKey: .contacts)
        let sortOptionRaw = try container.decode(String.self, forKey: .selectedSortOption)
        self.selectedSortOption = SortOption(rawValue: sortOptionRaw) ?? .name
        let sortDirectionRaw = try container.decode(String.self, forKey: .sortDirection)
        self.sortDirection = SortDirection(rawValue: sortDirectionRaw) ?? .ascending
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(contacts, forKey: .contacts)
        try container.encode(selectedSortOption.rawValue, forKey: .selectedSortOption)
        try container.encode(sortDirection.rawValue, forKey: .sortDirection)
    }
    
    mutating func addContact(_ contact: Contact) {
        contacts.append(contact)
        sortContacts()
    }
    
    mutating func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
    }
    
    mutating func sortContacts() {
        contacts.sort { first, second in
            let comparison: ComparisonResult
            
            switch selectedSortOption {
            case .name:
                comparison = first.firstName.localizedCaseInsensitiveCompare(second.firstName)
            case .age:
                if first.age < second.age {
                    comparison = .orderedAscending
                } else if first.age > second.age {
                    comparison = .orderedDescending
                } else {
                    comparison = .orderedSame
                }
            case .birthday:
                // Sort by calendar order (month and day only, ignoring year)
                let calendar = Calendar.current
                let firstMonth = calendar.component(.month, from: first.birthday)
                let firstDay = calendar.component(.day, from: first.birthday)
                let secondMonth = calendar.component(.month, from: second.birthday)
                let secondDay = calendar.component(.day, from: second.birthday)
                
                // First compare by month
                if firstMonth != secondMonth {
                    if firstMonth < secondMonth {
                        comparison = .orderedAscending
                    } else {
                        comparison = .orderedDescending
                    }
                } else {
                    // If same month, compare by day
                    if firstDay < secondDay {
                        comparison = .orderedAscending
                    } else if firstDay > secondDay {
                        comparison = .orderedDescending
                    } else {
                        comparison = .orderedSame
                    }
                }
            case .daysUntilBirthday:
                // Special handling for today's birthday (0 days) - they should come first
                if first.daysUntilNextBirthday == 0 && second.daysUntilNextBirthday != 0 {
                    comparison = .orderedAscending
                } else if first.daysUntilNextBirthday != 0 && second.daysUntilNextBirthday == 0 {
                    comparison = .orderedDescending
                } else {
                    // Normal comparison for other cases
                    if first.daysUntilNextBirthday < second.daysUntilNextBirthday {
                        comparison = .orderedAscending
                    } else if first.daysUntilNextBirthday > second.daysUntilNextBirthday {
                        comparison = .orderedDescending
                    } else {
                        comparison = .orderedSame
                    }
                }
            }
            
            // Apply sort direction
            switch sortDirection {
            case .ascending:
                return comparison == .orderedAscending
            case .descending:
                return comparison == .orderedDescending
            }
        }
    }
    
    mutating func toggleSortDirection() {
        sortDirection = sortDirection.next
        sortContacts()
    }
} 
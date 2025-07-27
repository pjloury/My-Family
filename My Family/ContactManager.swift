import Foundation
import SwiftUI
import Contacts

class ContactManager: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var selectedSortOption: SortOption = .name
    
    private let userDefaults = UserDefaults.standard
    private let contactsKey = "SavedContacts"
    
    init() {
        loadContacts()
    }
    
    func addContact(_ contact: Contact) {
        contacts.append(contact)
        sortContacts()
        saveContacts()
    }
    
    func createContact(from cnContact: CNContact, birthday: Date) -> Contact {
        let fullName = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces)
        let firstName = cnContact.givenName.trimmingCharacters(in: .whitespaces)
        let nickname = cnContact.nickname.isEmpty ? nil : cnContact.nickname
        let photoData = cnContact.imageData
        
        return Contact(name: fullName, firstName: firstName, nickname: nickname, birthday: birthday, photoData: photoData)
    }
    
    func saveBirthdayToContact(_ contact: CNContact, birthday: Date) async -> Bool {
        let store = CNContactStore()
        
        // Create a mutable copy of the contact
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        
        // Create birthday components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: birthday)
        let birthdayComponents = DateComponents(year: components.year, month: components.month, day: components.day)
        
        // Set the birthday
        mutableContact.birthday = birthdayComponents
        
        // Create save request
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)
        
        do {
            try store.execute(saveRequest)
            print("Successfully saved birthday for \(contact.givenName) \(contact.familyName)")
            return true
        } catch {
            print("Error saving birthday: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteContact(at offsets: IndexSet) {
        contacts.remove(atOffsets: offsets)
        saveContacts()
    }
    
    func sortContacts() {
        // Use a more efficient sorting approach
        contacts.sort { first, second in
            switch selectedSortOption {
            case .name:
                return first.firstName.localizedCaseInsensitiveCompare(second.firstName) == .orderedAscending
            case .age:
                return first.age > second.age
            case .birthday:
                // Sort by calendar order (month and day only, ignoring year)
                let calendar = Calendar.current
                let firstMonth = calendar.component(.month, from: first.birthday)
                let firstDay = calendar.component(.day, from: first.birthday)
                let secondMonth = calendar.component(.month, from: second.birthday)
                let secondDay = calendar.component(.day, from: second.birthday)
                
                // First compare by month
                if firstMonth != secondMonth {
                    return firstMonth < secondMonth
                }
                // If same month, compare by day
                return firstDay < secondDay
            case .daysUntilBirthday:
                return first.daysUntilNextBirthday < second.daysUntilNextBirthday
            }
        }
    }
    
    private func saveContacts() {
        if let encoded = try? JSONEncoder().encode(contacts) {
            userDefaults.set(encoded, forKey: contactsKey)
        }
    }
    
    private func loadContacts() {
        if let data = userDefaults.data(forKey: contactsKey),
           let decoded = try? JSONDecoder().decode([Contact].self, from: data) {
            contacts = decoded
            sortContacts()
        }
    }
    
    func requestContactsAccess() async -> Bool {
        let store = CNContactStore()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        print("Contact access status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Contacts access already authorized")
            return true
        case .denied, .restricted:
            print("Contacts access denied or restricted")
            return false
        case .notDetermined:
            print("Requesting contacts access...")
            return await withCheckedContinuation { continuation in
                store.requestAccess(for: .contacts) { granted, error in
                    print("Contacts access request result: granted=\(granted), error=\(error?.localizedDescription ?? "none")")
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            print("Unknown contacts access status")
            return false
        }
    }
    
    func fetchContacts() async -> [CNContact] {
        let store = CNContactStore()
        let keys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactBirthdayKey,
            CNContactImageDataKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactOrganizationNameKey,
            CNContactJobTitleKey,
            CNContactNicknameKey,
            CNContactRelationsKey
        ]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        var fetchedContacts: [CNContact] = []
        
        do {
            print("Starting to fetch contacts...")
            try store.enumerateContacts(with: request) { contact, stop in
                fetchedContacts.append(contact)
                if fetchedContacts.count % 100 == 0 {
                    print("Fetched \(fetchedContacts.count) contacts so far...")
                }
            }
            print("Successfully fetched \(fetchedContacts.count) total contacts")
            
            // Debug: Count contacts with birthdays
            let contactsWithBirthdays = fetchedContacts.filter { $0.birthday != nil }
            print("Contacts with birthdays: \(contactsWithBirthdays.count)")
            
            // Debug: Show some sample contacts
            for (index, contact) in fetchedContacts.prefix(5).enumerated() {
                print("Contact \(index + 1): \(contact.givenName) \(contact.familyName) - Birthday: \(contact.birthday?.description ?? "none")")
            }
            
        } catch {
            print("Error fetching contacts: \(error)")
        }
        
        return fetchedContacts
    }
} 
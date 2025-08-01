import Foundation
import SwiftUI
import Contacts
import UIKit

class ContactManager: ObservableObject {
    @Published var contactLists: [ContactList] = []
    @Published var selectedListIndex: Int = 0
    
    // Feature flag to toggle between flat UI colors and stock iOS colors
    static let useFlatUIColors = false
    
    private let contactStore = CNContactStore()
    private let fileManager = FileManager.default
    
    // Directory for storing contact photos
    private var photosDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("ContactPhotos")
    }
    
    private let contactListsKey = "SavedContactLists"
    private let selectedListIndexKey = "SelectedListIndex"
    
    private let userDefaults = UserDefaults.standard
    
    var currentList: ContactList? {
        guard selectedListIndex < contactLists.count else { return nil }
        return contactLists[selectedListIndex]
    }
    
    init() {
        createPhotosDirectoryIfNeeded()
        loadContactLists()
        
        // Create default "My Family" list if no lists exist
        if contactLists.isEmpty {
            let defaultList = ContactList(title: "My Family")
            contactLists.append(defaultList)
            saveContactLists()
        }
    }
    
    private func createPhotosDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: photosDirectory.path) {
            try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
        }
    }
    
    func savePhotoToFileSystem(_ photoData: Data, for contactId: UUID) -> String? {
        let fileName = "\(contactId.uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        
        do {
            try photoData.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    func loadPhotoFromFileSystem(fileName: String) -> Data? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        return try? Data(contentsOf: fileURL)
    }
    
    func deletePhotoFromFileSystem(fileName: String) {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func addContact(_ contact: Contact) {
        guard selectedListIndex < contactLists.count else { return }
        contactLists[selectedListIndex].addContact(contact)
        saveContactLists()
    }
    
    func createContact(from cnContact: CNContact, birthday: Date) -> Contact {
        let fullName = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespaces)
        let firstName = cnContact.givenName.trimmingCharacters(in: .whitespaces)
        let nickname = cnContact.nickname.isEmpty ? nil : cnContact.nickname
        
        var photoFileName: String? = nil
        if let photoData = cnContact.imageData {
            photoFileName = savePhotoToFileSystem(photoData, for: UUID())
        }
        
        // Get the first phone number if available
        let phoneNumber = cnContact.phoneNumbers.first?.value.stringValue
        
        return Contact(name: fullName, firstName: firstName, nickname: nickname, birthday: birthday, photoFileName: photoFileName, phoneNumber: phoneNumber)
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
        guard selectedListIndex < contactLists.count else { return }
        
        // Delete associated photos before removing contacts
        for index in offsets {
            let contact = contactLists[selectedListIndex].contacts[index]
            if let photoFileName = contact.photoFileName {
                deletePhotoFromFileSystem(fileName: photoFileName)
            }
        }
        
        contactLists[selectedListIndex].deleteContact(at: offsets)
        saveContactLists()
    }
    
    func sortContacts() {
        guard let currentListIndex = contactLists.firstIndex(where: { $0.id == (currentList?.id ?? UUID()) }) else { return }
        
        contactLists[currentListIndex].contacts.sort { (first: Contact, second: Contact) in
            let comparison: ComparisonResult
            
            switch contactLists[currentListIndex].selectedSortOption {
            case .name:
                comparison = first.firstName.localizedCaseInsensitiveCompare(second.firstName)
            case .age:
                comparison = first.age < second.age ? .orderedAscending : first.age > second.age ? .orderedDescending : .orderedSame
            case .birthday:
                let firstMonth = Calendar.current.component(.month, from: first.birthday)
                let firstDay = Calendar.current.component(.day, from: first.birthday)
                let secondMonth = Calendar.current.component(.month, from: second.birthday)
                let secondDay = Calendar.current.component(.day, from: second.birthday)
                
                if firstMonth < secondMonth {
                    comparison = .orderedAscending
                } else if firstMonth > secondMonth {
                    comparison = .orderedDescending
                } else {
                    comparison = firstDay < secondDay ? .orderedAscending : firstDay > secondDay ? .orderedDescending : .orderedSame
                }
            case .daysUntilBirthday:
                comparison = first.daysUntilNextBirthday < second.daysUntilNextBirthday ? .orderedAscending : first.daysUntilNextBirthday > second.daysUntilNextBirthday ? .orderedDescending : .orderedSame
            @unknown default:
                comparison = first.firstName.localizedCaseInsensitiveCompare(second.firstName)
            }
            
            // Apply sort direction
            switch contactLists[currentListIndex].sortDirection {
            case .ascending:
                return comparison == .orderedAscending
            case .descending:
                return comparison == .orderedDescending
            @unknown default:
                return comparison == .orderedAscending
            }
        }
        
        saveContactLists()
    }
    
    func toggleSortDirection() {
        guard selectedListIndex < contactLists.count else { return }
        contactLists[selectedListIndex].toggleSortDirection()
        saveContactLists()
    }
    
    func updateSortOption(_ option: SortOption) {
        guard selectedListIndex < contactLists.count else { return }
        contactLists[selectedListIndex].selectedSortOption = option
        contactLists[selectedListIndex].sortContacts()
        saveContactLists()
    }
    
    func addNewList(title: String) {
        let newList = ContactList(title: title)
        contactLists.append(newList)
        selectedListIndex = contactLists.count - 1
        saveContactLists()
    }
    
    func deleteList(at index: Int) {
        guard index < contactLists.count else { return }
        
        // Delete associated photos for all contacts in the list
        for contact in contactLists[index].contacts {
            if let photoFileName = contact.photoFileName {
                deletePhotoFromFileSystem(fileName: photoFileName)
            }
        }
        
        contactLists.remove(at: index)
        
        // Adjust selected index if necessary
        if selectedListIndex >= contactLists.count {
            selectedListIndex = max(0, contactLists.count - 1)
        }
        
        saveContactLists()
    }
    
    func updateCurrentListTitle(_ newTitle: String) {
        guard selectedListIndex < contactLists.count else { return }
        contactLists[selectedListIndex].title = newTitle
        saveContactLists()
    }
    
    func getCurrentListColors() -> (primary: Color, secondary: Color) {
        if ContactManager.useFlatUIColors {
            // Flat UI colors
            let colors: [Color] = [
                Color(red: 0.925, green: 0.235, blue: 0.235), // Flat Red
                Color(red: 0.925, green: 0.431, blue: 0.235), // Flat Orange
                Color(red: 0.925, green: 0.627, blue: 0.235), // Flat Yellow
                Color(red: 0.235, green: 0.925, blue: 0.235), // Flat Green
                Color(red: 0.235, green: 0.627, blue: 0.925), // Flat Blue
                Color(red: 0.627, green: 0.235, blue: 0.925), // Flat Purple
            ]
            
            let primaryColor = colors[selectedListIndex % colors.count]
            let secondaryColor = primaryColor.opacity(0.3)
            return (primary: primaryColor, secondary: secondaryColor)
        } else {
            // Stock iOS colors - return clear to use defaults
            return (primary: Color.clear, secondary: Color.clear)
        }
    }
    
    func deleteCurrentList() {
        guard selectedListIndex < contactLists.count else { return }
        
        // Delete associated photos
        for contact in contactLists[selectedListIndex].contacts {
            if let photoFileName = contact.photoFileName {
                deletePhotoFromFileSystem(fileName: photoFileName)
            }
        }
        
        // Remove the list
        contactLists.remove(at: selectedListIndex)
        
        // Adjust selected index if necessary
        if contactLists.isEmpty {
            // Create a default list if all lists are deleted
            let defaultList = ContactList(title: "My Family")
            contactLists.append(defaultList)
            selectedListIndex = 0
        } else if selectedListIndex >= contactLists.count {
            selectedListIndex = contactLists.count - 1
        }
        
        saveContactLists()
    }
    
    func saveContactLists() {
        if let encoded = try? JSONEncoder().encode(contactLists) {
            userDefaults.set(encoded, forKey: contactListsKey)
        }
        userDefaults.set(selectedListIndex, forKey: selectedListIndexKey)
    }
    
    private func loadContactLists() {
        if let data = userDefaults.data(forKey: contactListsKey),
           let decoded = try? JSONDecoder().decode([ContactList].self, from: data) {
            contactLists = decoded
        }
        
        selectedListIndex = userDefaults.integer(forKey: selectedListIndexKey)
        if selectedListIndex >= contactLists.count {
            selectedListIndex = 0
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
        case .denied:
            print("Contacts access denied")
            return false
        case .restricted:
            print("Contacts access restricted")
            return false
        case .limited:
            print("Contacts access limited")
            return true
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
    
    func updateContact(contactId: UUID, name: String, firstName: String, birthday: Date, photoData: Data?, phoneNumber: String?) {
        guard let listIndex = contactLists.firstIndex(where: { $0.id == (currentList?.id ?? UUID()) }),
              let contactIndex = contactLists[listIndex].contacts.firstIndex(where: { $0.id == contactId }) else {
            return
        }
        
        var updatedContact = contactLists[listIndex].contacts[contactIndex]
        updatedContact.name = name
        updatedContact.firstName = firstName
        updatedContact.birthday = birthday
        updatedContact.phoneNumber = phoneNumber
        
        // Handle photo changes
        if let newPhotoData = photoData {
            // Check if this is actually a new photo or just preserving the existing one
            if let existingPhotoFileName = updatedContact.photoFileName {
                // Try to load the existing photo data to compare
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let existingFilePath = documentsDirectory.appendingPathComponent("ContactPhotos").appendingPathComponent(existingPhotoFileName)
                
                do {
                    let existingPhotoData = try Data(contentsOf: existingFilePath)
                    if existingPhotoData == newPhotoData {
                        // Same photo data, don't change anything
                        print("Photo data unchanged, preserving existing photo file")
                    } else {
                        // Different photo data, save new photo and delete old one
                        print("Photo data changed, saving new photo")
                        let photoFileName = savePhotoToFileSystem(newPhotoData, for: contactId)
                        deletePhotoFromFileSystem(fileName: existingPhotoFileName)
                        updatedContact.photoFileName = photoFileName
                    }
                } catch {
                    // Existing photo file not found, save the new one
                    print("Existing photo file not found, saving new photo")
                    let photoFileName = savePhotoToFileSystem(newPhotoData, for: contactId)
                    updatedContact.photoFileName = photoFileName
                }
            } else {
                // No existing photo, save the new one
                print("No existing photo, saving new photo")
                let photoFileName = savePhotoToFileSystem(newPhotoData, for: contactId)
                updatedContact.photoFileName = photoFileName
            }
        } else {
            // If no new photo data provided, preserve the existing photo filename
            // (This prevents losing the photo when only editing name/birthday)
            // The photoFileName is already set in updatedContact, so we don't need to change it
            print("No photo data provided, preserving existing photo")
        }
        
        contactLists[listIndex].contacts[contactIndex] = updatedContact
        print("Updated contact: \(updatedContact.name), photoFileName: \(updatedContact.photoFileName ?? "nil")")
        saveContactLists()
    }
    
    func getContact(by id: UUID) -> Contact? {
        for list in contactLists {
            if let contact = list.contacts.first(where: { $0.id == id }) {
                return contact
            }
        }
        return nil
    }
} 

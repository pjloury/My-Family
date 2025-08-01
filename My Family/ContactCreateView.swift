import SwiftUI
import PhotosUI
import UIKit
import Contacts

struct ContactCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var contactManager: ContactManager
    @Binding var dismissParent: Bool
    
    @State private var editedFirstName: String = ""
    @State private var editedLastName: String = ""
    @State private var editedPhoneNumber: String = ""
    @State private var editedBirthday: Date = Date()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editedPhotoData: Data?
    @State private var showingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter first name", text: $editedFirstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter last name", text: $editedLastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter phone number", text: $editedPhoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                }
                
                Section("Birthday") {
                    DatePicker("Birthday", selection: $editedBirthday, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section("Photo") {
                    HStack {
                        if let photoData = editedPhotoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Button("Add Photo") {
                                showingPhotoPicker = true
                            }
                            .foregroundColor(.blue)
                            
                            if editedPhotoData != nil {
                                Button("Remove Photo") {
                                    editedPhotoData = nil
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            if let photoData = editedPhotoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(fullName.isEmpty ? "New Contact" : fullName) • \(calculateAge())")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 4) {
                                    Text(formatBirthday())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(calculateZodiacSign())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(calculateChineseZodiac())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(calculateMonthsUntilBirthday())
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("til next b-day")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Create New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        createContact()
                        dismiss()
                        dismissParent = true
                    }
                    .disabled(fullName.isEmpty)
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { oldValue, newValue in
                if let selectedPhoto = selectedPhoto {
                    selectedPhoto.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data {
                                editedPhotoData = data
                            }
                        case .failure(let error):
                            print("Failed to load photo: \(error)")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var fullName: String {
        let firstName = editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = editedLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if firstName.isEmpty && lastName.isEmpty {
            return ""
        } else if lastName.isEmpty {
            return firstName
        } else if firstName.isEmpty {
            return lastName
        } else {
            return "\(firstName) \(lastName)"
        }
    }
    
    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: editedBirthday, to: now)
        return ageComponents.year ?? 0
    }
    
    private func formatBirthday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: editedBirthday)
    }
    
    private func calculateZodiacSign() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: editedBirthday)
        let day = calendar.component(.day, from: editedBirthday)
        
        switch (month, day) {
        case (1, 1...19), (12, 22...31):
            return "♑"
        case (1, 20...31), (2, 1...18):
            return "♒"
        case (2, 19...29), (3, 1...20):
            return "♓"
        case (3, 21...31), (4, 1...19):
            return "♈"
        case (4, 20...30), (5, 1...20):
            return "♉"
        case (5, 21...31), (6, 1...20):
            return "♊"
        case (6, 21...30), (7, 1...22):
            return "♋"
        case (7, 23...31), (8, 1...22):
            return "♌"
        case (8, 23...31), (9, 1...22):
            return "♍"
        case (9, 23...30), (10, 1...22):
            return "♎"
        case (10, 23...31), (11, 1...21):
            return "♏"
        case (11, 22...30), (12, 1...21):
            return "♐"
        default:
            return "♑"
        }
    }
    
    private func calculateChineseZodiac() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: editedBirthday)
        let month = calendar.component(.month, from: editedBirthday)
        let day = calendar.component(.day, from: editedBirthday)
        
        // Lunar New Year dates (simplified for preview)
        let lunarNewYearDates: [Int: (month: Int, day: Int)] = [
            2020: (1, 25), 2021: (2, 12), 2022: (2, 1), 2023: (1, 22), 2024: (2, 10), 2025: (1, 29)
        ]
        
        var effectiveYear = year
        
        if let lunarNewYear = lunarNewYearDates[year] {
            let birthDate = (month, day)
            let lunarDate = lunarNewYear
            
            if birthDate < lunarDate {
                effectiveYear = year - 1
            }
        }
        
        let zodiacYear = (effectiveYear - 1900) % 12
        
        switch zodiacYear {
        case 0: return "🐀"
        case 1: return "🐂"
        case 2: return "🐅"
        case 3: return "🐇"
        case 4: return "🐉"
        case 5: return "🐍"
        case 6: return "🐎"
        case 7: return "🐐"
        case 8: return "🐒"
        case 9: return "🐓"
        case 10: return "🐕"
        case 11: return "🐖"
        default: return "🐀"
        }
    }
    
    private func calculateMonthsUntilBirthday() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(from: DateComponents(year: thisYear, month: calendar.component(.month, from: editedBirthday), day: calendar.component(.day, from: editedBirthday))) ?? editedBirthday
        
        if nextBirthday < now {
            nextBirthday = calendar.date(from: DateComponents(year: thisYear + 1, month: calendar.component(.month, from: editedBirthday), day: calendar.component(.day, from: editedBirthday))) ?? editedBirthday
        }
        
        let components = calendar.dateComponents([.month, .day], from: now, to: nextBirthday)
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        let totalDays = (months * 30) + days
        let roundedMonths = totalDays / 30
        
        if roundedMonths < 1 {
            let dayText = totalDays == 1 ? "day" : "days"
            return "\(totalDays) \(dayText)"
        } else {
            let monthText = roundedMonths == 1 ? "month" : "months"
            return "\(roundedMonths) \(monthText)"
        }
    }
    
    private func createContact() {
        // Create a new Contact object
        var newContact = Contact(
            name: fullName,
            firstName: editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines),
            nickname: nil,
            birthday: editedBirthday,
            photoFileName: nil,
            phoneNumber: editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Save photo if available
        if let photoData = editedPhotoData {
            newContact.photoFileName = contactManager.savePhotoToFileSystem(photoData, for: newContact.id)
        }
        
        // Add to family list
        contactManager.addContact(newContact)
        
        // Save to device contacts
        Task {
            await saveToDeviceContacts(newContact)
        }
    }
    
    private func saveToDeviceContacts(_ contact: Contact) async {
        let store = CNContactStore()
        
        do {
            // Create a new mutable contact
            let newContact = CNMutableContact()
            
            // Set the name
            newContact.givenName = editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
            newContact.familyName = editedLastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Set the phone number if provided
            if !editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let phoneNumber = CNPhoneNumber(stringValue: editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))
                newContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: phoneNumber)]
            }
            
            // Set the birthday
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: contact.birthday)
            newContact.birthday = components
            
            // Set the photo if available
            if let photoData = editedPhotoData {
                newContact.imageData = photoData
            }
            
            // Save to device contacts
            let saveRequest = CNSaveRequest()
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
            
            try store.execute(saveRequest)
            print("Successfully created new contact in device")
            
        } catch {
            print("Failed to create contact in device: \(error)")
        }
    }
}

#Preview {
    ContactCreateView(contactManager: ContactManager(), dismissParent: .constant(false))
} 
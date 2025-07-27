import SwiftUI
import PhotosUI
import UIKit

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var contactManager: ContactManager
    let contact: Contact
    
    @State private var editedName: String
    @State private var editedFirstName: String
    @State private var editedBirthday: Date
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editedPhotoData: Data?
    @State private var showingPhotoPicker = false
    
    init(contact: Contact, contactManager: ContactManager) {
        self.contact = contact
        self.contactManager = contactManager
        self._editedName = State(initialValue: contact.name)
        self._editedFirstName = State(initialValue: contact.firstName)
        self._editedBirthday = State(initialValue: contact.birthday)
        
        // Load existing photo data if available
        if let photoFileName = contact.photoFileName {
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent("ContactPhotos").appendingPathComponent(photoFileName)
            self._editedPhotoData = State(initialValue: try? Data(contentsOf: filePath))
        } else {
            self._editedPhotoData = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Contact Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter full name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter first name", text: $editedFirstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                            Button("Change Photo") {
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
                                Text("\(editedName) • \(calculateAge())")
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
            .navigationTitle("Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                        dismiss()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        editedPhotoData = data
                    }
                }
            }
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
            return "\(totalDays) days"
        } else {
            return "\(roundedMonths) months"
        }
    }
    
    private func saveContact() {
        // Find the contact in the current list and update it
        if let currentList = contactManager.currentList,
           let index = currentList.contacts.firstIndex(where: { $0.id == contact.id }) {
            var newPhotoFileName: String? = nil
            
            // Handle photo changes
            if let newPhotoData = editedPhotoData {
                // Save new photo to file system
                newPhotoFileName = contactManager.savePhotoToFileSystem(newPhotoData, for: contact.id)
                
                // Delete old photo if it exists and is different
                if let oldPhotoFileName = contact.photoFileName, oldPhotoFileName != newPhotoFileName {
                    contactManager.deletePhotoFromFileSystem(fileName: oldPhotoFileName)
                }
            } else if contact.photoFileName != nil {
                // Photo was removed, delete old photo
                contactManager.deletePhotoFromFileSystem(fileName: contact.photoFileName!)
            }
            
            let updatedContact = Contact(
                name: editedName.trimmingCharacters(in: .whitespacesAndNewlines),
                firstName: editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines),
                nickname: contact.nickname,
                birthday: editedBirthday,
                photoFileName: newPhotoFileName
            )
            
            // Update the contact in the current list
            contactManager.contactLists[contactManager.selectedListIndex].contacts[index] = updatedContact
            contactManager.sortContacts()
            contactManager.saveContactLists()
        }
    }
}

#Preview {
    ContactEditView(
        contact: Contact(
            name: "John Doe",
            firstName: "John",
            nickname: nil,
            birthday: Date().addingTimeInterval(-30*365*24*60*60),
            photoFileName: nil
        ),
        contactManager: ContactManager()
    )
} 
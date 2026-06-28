import SwiftUI
import PhotosUI
import UIKit
import Contacts // Added for CNContactStore

struct ContactEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var contactManager: ContactManager
    let contact: Contact
    var embedded: Bool = false
    @Binding var shouldSave: Bool
    
    @State private var editedFirstName: String
    @State private var editedLastName: String
    @State private var editedPhoneNumber: String
    @State private var editedBirthday: Date
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editedPhotoData: Data?
    @State private var showingPhotoPicker = false
    @State private var isDeceased: Bool
    @State private var deceasedDate: Date
    @State private var showingDeceasedDatePicker = false
    @State private var specialDates: [SpecialDate]
    @State private var relation: Relation?
    @State private var relationQuery: String
    @FocusState private var relationFieldFocused: Bool

    init(contact: Contact, contactManager: ContactManager, embedded: Bool = false, shouldSave: Binding<Bool> = .constant(false)) {
        self.contact = contact
        self.contactManager = contactManager
        self.embedded = embedded
        self._shouldSave = shouldSave

        // Parse the full name into first and last name
        let nameParts = contact.name.split(separator: " ", maxSplits: 1)
        let firstName = nameParts.count > 0 ? String(nameParts[0]) : ""
        let lastName = nameParts.count > 1 ? String(nameParts[1]) : ""

        self._editedFirstName = State(initialValue: firstName)
        self._editedLastName = State(initialValue: lastName)
        self._editedPhoneNumber = State(initialValue: contact.phoneNumber ?? "")
        self._editedBirthday = State(initialValue: contact.birthday)
        self._isDeceased = State(initialValue: contact.deceasedDate != nil)
        self._deceasedDate = State(initialValue: contact.deceasedDate ?? Date())
        self._specialDates = State(initialValue: contact.specialDates)
        self._relation = State(initialValue: contact.relation)
        self._relationQuery = State(initialValue: contact.relation?.displayName ?? "")
        
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
        if embedded {
            formContent
        } else {
            NavigationView {
                formContent
                    .navigationTitle("Edit Contact")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") { dismiss() }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                saveContact()
                                dismiss()
                            }
                            .disabled(fullName.isEmpty)
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
    }

    private var formContent: some View {
        ScrollViewReader { proxy in
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
                
                let relationMatches: [Relation] = relationQuery.isEmpty
                    ? Relation.allCases.filter { $0 != .other }
                    : Relation.allCases.filter { $0 != .other && $0.displayName.localizedCaseInsensitiveContains(relationQuery) }
                let showOther = !relationQuery.isEmpty && relationMatches.isEmpty

                Section("Relation") {
                    TextField("Search relation…", text: $relationQuery)
                        .focused($relationFieldFocused)
                        .onChange(of: relationQuery) { _, _ in
                            if Relation.from(string: relationQuery) == nil {
                                relation = nil
                            }
                        }
                        .submitLabel(.done)
                        .onSubmit { relationFieldFocused = false }
                        .onChange(of: relationFieldFocused) { _, focused in
                            if focused {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    withAnimation { proxy.scrollTo("relationSection", anchor: .top) }
                                }
                            }
                        }

                    if relationFieldFocused {
                        ForEach(relationMatches, id: \.self) { r in
                            Button {
                                relation = r
                                relationQuery = r.displayName
                                relationFieldFocused = false
                            } label: {
                                HStack {
                                    Text(r.displayName)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .opacity(relation == r ? 1 : 0)
                                }
                            }
                        }
                        if showOther {
                            Button {
                                relation = .other
                                relationQuery = Relation.other.displayName
                                relationFieldFocused = false
                            } label: {
                                HStack {
                                    Text(Relation.other.displayName)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .opacity(relation == .other ? 1 : 0)
                                }
                            }
                        }
                    }
                }
                .id("relationSection")

                Section("Birthday") {
                    DatePicker("Birthday", selection: $editedBirthday, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                }

                Section {
                    if isDeceased {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Passed Away", systemImage: "leaf")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Remove") {
                                    withAnimation {
                                        isDeceased = false
                                        showingDeceasedDatePicker = false
                                    }
                                }
                                .foregroundColor(.red)
                                .font(.callout)
                            }
                            DatePicker("Date of Passing", selection: $deceasedDate, in: editedBirthday...Date(), displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                        }
                    } else {
                        Button {
                            withAnimation {
                                isDeceased = true
                                showingDeceasedDatePicker = true
                            }
                        } label: {
                            Label("Mark as Passed Away", systemImage: "leaf")
                                .foregroundColor(.secondary)
                                .font(.callout)
                        }
                    }
                } header: {
                    Text("In Memory")
                } footer: {
                    if isDeceased {
                        Text("Birthday reminders will still appear, celebrating their memory.")
                            .font(.caption)
                    }
                }
                
                Section {
                    ForEach($specialDates) { $sd in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                TextField("Label (e.g. Anniversary)", text: $sd.label)
                                    .font(.subheadline)
                                Spacer()
                                Button {
                                    specialDates.removeAll { $0.id == sd.id }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            DatePicker("", selection: $sd.date, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                            HStack(spacing: 16) {
                                Toggle(isOn: $sd.calendarReminderEnabled) {
                                    Label("Calendar", systemImage: "calendar")
                                        .font(.caption)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                Toggle(isOn: $sd.notificationsEnabled) {
                                    Label("Reminder", systemImage: "bell")
                                        .font(.caption)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }

                    Button {
                        specialDates.append(SpecialDate(date: Date(), label: ""))
                    } label: {
                        Label("Add Date", systemImage: "calendar.badge.plus")
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                } header: {
                    Text("Other Dates")
                } footer: {
                    if specialDates.isEmpty {
                        Text("Add anniversaries, milestones, or any recurring date.")
                            .font(.caption)
                    }
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
                                Text("\(fullName) • \(calculateAge())")
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
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhoto, matching: .images)
            .onChange(of: selectedPhoto) { _, _ in
                if let selectedPhoto = selectedPhoto {
                    selectedPhoto.loadTransferable(type: Data.self) { result in
                        if case .success(let data) = result, let data = data {
                            editedPhotoData = data
                        }
                    }
                }
            }
            .onChange(of: shouldSave) { _, newValue in
                if newValue {
                    saveContact()
                    shouldSave = false
                }
            }
        } // ScrollViewReader
    }

    func save() {
        saveContact()
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
    
    private func loadExistingPhotoData() -> Data? {
        // Get the updated contact from the contact manager
        guard let updatedContact = contactManager.getContact(by: contact.id) else { 
            print("Could not find updated contact")
            return nil 
        }
        
        guard let photoFileName = updatedContact.photoFileName else { 
            print("No photoFileName for updated contact: \(updatedContact.name)")
            return nil 
        }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsDirectory.appendingPathComponent("ContactPhotos").appendingPathComponent(photoFileName)
        
        do {
            let photoData = try Data(contentsOf: filePath)
            print("Successfully loaded existing photo for updated contact: \(updatedContact.name)")
            return photoData
        } catch {
            print("Error loading existing photo for updated contact \(updatedContact.name): \(error.localizedDescription)")
            return nil
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
        
        // Lunar New Year dates (approximate, may vary by 1-2 days)
        // These are the dates when the new year started for each year
        let lunarNewYearDates: [Int: (month: Int, day: Int)] = [
            1900: (1, 30), 1901: (2, 19), 1902: (2, 8), 1903: (1, 29), 1904: (2, 16), 1905: (2, 4),
            1906: (1, 25), 1907: (2, 13), 1908: (2, 2), 1909: (1, 22), 1910: (2, 10), 1911: (1, 30),
            1912: (2, 18), 1913: (2, 6), 1914: (1, 26), 1915: (2, 14), 1916: (2, 3), 1917: (1, 23),
            1918: (2, 11), 1919: (2, 1), 1920: (2, 20), 1921: (2, 8), 1922: (1, 28), 1923: (2, 16),
            1924: (2, 5), 1925: (1, 25), 1926: (2, 13), 1927: (2, 2), 1928: (1, 23), 1929: (2, 10),
            1930: (1, 30), 1931: (2, 17), 1932: (2, 6), 1933: (1, 26), 1934: (2, 14), 1935: (2, 4),
            1936: (1, 24), 1937: (2, 11), 1938: (1, 31), 1939: (2, 19), 1940: (2, 8), 1941: (1, 27),
            1942: (2, 15), 1943: (2, 5), 1944: (1, 25), 1945: (2, 13), 1946: (2, 2), 1947: (1, 22),
            1948: (2, 10), 1949: (1, 29), 1950: (2, 17), 1951: (2, 6), 1952: (1, 27), 1953: (2, 14),
            1954: (2, 3), 1955: (1, 24), 1956: (2, 12), 1957: (1, 31), 1958: (2, 18), 1959: (2, 8),
            1960: (1, 28), 1961: (2, 15), 1962: (2, 5), 1963: (1, 25), 1964: (2, 13), 1965: (2, 2),
            1966: (1, 21), 1967: (2, 9), 1968: (1, 30), 1969: (2, 17), 1970: (2, 6), 1971: (1, 27),
            1972: (2, 15), 1973: (2, 3), 1974: (1, 23), 1975: (2, 11), 1976: (1, 31), 1977: (2, 18),
            1978: (2, 7), 1979: (1, 28), 1980: (2, 16), 1981: (2, 5), 1982: (1, 25), 1983: (2, 13),
            1984: (2, 2), 1985: (1, 21), 1986: (2, 9), 1987: (1, 29), 1988: (2, 17), 1989: (2, 6),
            1990: (1, 27), 1991: (2, 15), 1992: (2, 4), 1993: (1, 23), 1994: (2, 10), 1995: (1, 31),
            1996: (2, 19), 1997: (2, 7), 1998: (1, 28), 1999: (2, 16), 2000: (2, 5), 2001: (1, 24),
            2002: (2, 12), 2003: (2, 1), 2004: (1, 22), 2005: (2, 9), 2006: (1, 29), 2007: (2, 18),
            2008: (2, 7), 2009: (1, 26), 2010: (2, 14), 2011: (2, 3), 2012: (1, 23), 2013: (2, 10),
            2014: (1, 31), 2015: (2, 19), 2016: (2, 8), 2017: (1, 28), 2018: (2, 16), 2019: (2, 5),
            2020: (1, 25), 2021: (2, 12), 2022: (2, 1), 2023: (1, 22), 2024: (2, 10), 2025: (1, 29),
            2026: (2, 17), 2027: (2, 6), 2028: (1, 26), 2029: (2, 13), 2030: (2, 3), 2031: (1, 23),
            2032: (2, 11), 2033: (1, 31), 2034: (2, 19), 2035: (2, 8), 2036: (1, 28), 2037: (2, 15),
            2038: (2, 4), 2039: (1, 24), 2040: (2, 12), 2041: (2, 1), 2042: (1, 22), 2043: (2, 10)
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
    
    private func saveContact() {
        // Determine what photo data to pass
        let photoDataToSave: Data?
        if let newPhotoData = editedPhotoData {
            // User selected a new photo
            photoDataToSave = newPhotoData
        } else if let existingPhotoData = loadExistingPhotoData() {
            // User didn't change photo, but we need to preserve the existing one
            photoDataToSave = existingPhotoData
        } else {
            // No photo at all
            photoDataToSave = nil
        }
        
        // Update the contact in the contact manager
        contactManager.updateContact(
            contactId: contact.id,
            name: fullName,
            firstName: editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines),
            birthday: editedBirthday,
            photoData: photoDataToSave,
            phoneNumber: editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            deceasedDate: isDeceased ? deceasedDate : nil,
            specialDates: specialDates,
            relation: relation
        )
        
        // Save changes back to iOS Contacts
        Task {
            await saveToSystemContacts()
        }
    }

    private func saveToSystemContacts() async {
        let store = CNContactStore()
        
        do {
            // Fetch the original contact from iOS Contacts
            let predicate = CNContact.predicateForContacts(matchingName: contact.name)
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor
            ]
            
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            
            guard let systemContact = contacts.first else {
                print("Could not find contact in system")
                return
            }
            
            // Create a mutable copy
            let mutableContact = systemContact.mutableCopy() as! CNMutableContact
            
            // Update the fields
            mutableContact.givenName = editedFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
            mutableContact.familyName = editedLastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Update phone number if provided
            if !editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let phoneNumber = CNPhoneNumber(stringValue: editedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))
                mutableContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: phoneNumber)]
            }
            
            // Update birthday
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: editedBirthday)
            mutableContact.birthday = components
            
            // Update photo if changed
            if let newPhotoData = editedPhotoData {
                mutableContact.imageData = newPhotoData
            }
            
            // Save to system
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            
            try store.execute(saveRequest)
            print("Successfully updated contact in system")
            
        } catch {
            print("Failed to update system contact: \(error)")
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
            photoFileName: nil,
            phoneNumber: nil
        ),
        contactManager: ContactManager()
    )
} 
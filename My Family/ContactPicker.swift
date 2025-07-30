import SwiftUI
import Contacts
import UIKit

struct ContactPicker: View {
    @ObservedObject var contactManager: ContactManager
    @Environment(\.dismiss) private var dismiss
    @State private var deviceContacts: [CNContact] = []
    @State private var filteredContacts: [CNContact] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var debugInfo = ""
    @State private var showingBirthdayInput = false
    @State private var selectedContact: CNContact?
    @State private var suggestedContacts: [CNContact] = []
    @State private var contactScores: [String: Int] = [:]
    @State private var displayNames: [String: String] = [:]
    @State private var debouncedSearchText = ""
    @State private var showingCreateContact = false
    @State private var dismissContactPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading contacts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if deviceContacts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No contacts found")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("Make sure you have contacts in your device's contact list.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Debug info
                        if !debugInfo.isEmpty {
                            Text("Debug: \(debugInfo)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button("Retry Loading") {
                            Task {
                                await loadContacts()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search contacts...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .onChange(of: searchText) {
                                    // If search text is empty, update immediately without debouncing
                                    if searchText.isEmpty {
                                        debouncedSearchText = ""
                                        filterContacts()
                                    } else {
                                        // Debounce search to reduce filtering frequency
                                        Task {
                                            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
                                            await MainActor.run {
                                                debouncedSearchText = searchText
                                                filterContacts()
                                            }
                                        }
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button("Clear") {
                                    searchText = ""
                                    debouncedSearchText = ""
                                    filterContacts()
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Contact List
                        List {
                            // Suggested Contacts Section (only show when not searching)
                            if !debouncedSearchText.isEmpty {
                                // When searching, show all filtered contacts
                                ForEach(filteredContacts, id: \.identifier) { contact in
                                    ContactPickerRow(
                                        contact: contact,
                                        onTap: {
                                            addContactToFamily(contact)
                                        },
                                        isAlreadyAdded: isContactAlreadyAdded(contact)
                                    )
                                }
                            } else {
                                // When not searching, show suggested section and all contacts
                                if !suggestedContacts.isEmpty {
                                    Section("Suggested") {
                                        ForEach(suggestedContacts, id: \.identifier) { contact in
                                            ContactPickerRow(
                                                contact: contact,
                                                onTap: {
                                                    addContactToFamily(contact)
                                                },
                                                isAlreadyAdded: isContactAlreadyAdded(contact)
                                            )
                                        }
                                    }
                                }
                                
                                Section("All Contacts") {
                                    ForEach(filteredContacts, id: \.identifier) { contact in
                                        ContactPickerRow(
                                            contact: contact,
                                            onTap: {
                                                addContactToFamily(contact)
                                            },
                                            isAlreadyAdded: isContactAlreadyAdded(contact)
                                        )
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .animation(.easeInOut(duration: 0.2), value: debouncedSearchText.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateContact = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .task {
            await loadContacts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingBirthdayInput) {
            if let contact = selectedContact {
                BirthdayInputView(contact: contact) { birthday in
                    Task {
                        await handleBirthdaySelected(contact: contact, birthday: birthday)
                    }
                } onCancel: {
                    showingBirthdayInput = false
                    selectedContact = nil
                }
            }
        }
        .sheet(isPresented: $showingCreateContact) {
            ContactCreateView(contactManager: contactManager, dismissParent: $dismissContactPicker)
        }
        .onChange(of: dismissContactPicker) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func loadContacts() async {
        isLoading = true
        debugInfo = "Starting contact load..."
        
        let hasAccess = await contactManager.requestContactsAccess()
        debugInfo += "\nAccess granted: \(hasAccess)"
        
        if hasAccess {
            let contacts = await contactManager.fetchContacts()
            await MainActor.run {
                debugInfo += "\nTotal contacts fetched: \(contacts.count)"
                
                // Filter out contacts without names and show only valid contacts
                deviceContacts = contacts.filter { contact in
                    hasValidName(contact)
                }
                
                // Sort contacts by relevance (family members first)
                deviceContacts.sort { contact1, contact2 in
                    let score1 = calculateFamilyScore(contact1)
                    let score2 = calculateFamilyScore(contact2)
                    return score1 > score2
                }
                
                // Clear caches when contacts are reloaded
                contactScores.removeAll()
                displayNames.removeAll()
                
                filteredContacts = deviceContacts
                suggestedContacts = getHighConfidenceSuggestions()
                debugInfo += "\nFinal contacts to display: \(filteredContacts.count)"
                debugInfo += "\nSuggested contacts: \(suggestedContacts.count)"
                isLoading = false
            }
        } else {
            await MainActor.run {
                errorMessage = "Please grant access to contacts in Settings to add family members."
                debugInfo += "\nAccess denied"
                showError = true
                isLoading = false
            }
        }
    }
    
    private func getHighConfidenceSuggestions() -> [CNContact] {
        // Only include contacts that have related names with predefined label types
        let contactsWithRelatedNames = deviceContacts.filter { contact in
            // Check for related names with predefined label types
            return contact.contactRelations.contains { relation in
                // Only include predefined family-related label types
                let predefinedLabels: Set<String> = [
                    CNLabelContactRelationFather,
                    CNLabelContactRelationMother,
                    CNLabelContactRelationParent,
                    CNLabelContactRelationBrother,
                    CNLabelContactRelationSister,
                    CNLabelContactRelationChild,
                    CNLabelContactRelationSon,
                    CNLabelContactRelationDaughter,
                    CNLabelContactRelationSpouse,
                    CNLabelContactRelationPartner
                ]
                
                return predefinedLabels.contains(relation.label ?? "")
            }
        }
        
        // Pre-calculate scores for filtered contacts if not already cached
        for contact in contactsWithRelatedNames {
            _ = calculateFamilyScore(contact)
        }
        
        let contactsWithScores = contactsWithRelatedNames.map { contact in
            (contact: contact, score: contactScores[contact.identifier] ?? 0)
        }
        
        // Sort by score descending, then alphabetically
        let sortedContacts = contactsWithScores
            .sorted { first, second in
                if first.score == second.score {
                    // If scores are equal, sort alphabetically by display name
                    let firstName = getDisplayName(first.contact)
                    let secondName = getDisplayName(second.contact)
                    return firstName.localizedCaseInsensitiveCompare(secondName) == .orderedAscending
                }
                return first.score > second.score
            }
            .map { $0.contact }
        
        // Return up to 6 suggestions
        return Array(sortedContacts.prefix(6))
    }
    
    private func getDisplayName(_ contact: CNContact) -> String {
        let contactId = contact.identifier
        
        // Return cached display name if available
        if let cachedName = displayNames[contactId] {
            return cachedName
        }
        
        let displayName: String
        if !contact.nickname.isEmpty {
            displayName = contact.nickname
        } else {
            displayName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        }
        
        // Cache the display name
        displayNames[contactId] = displayName
        return displayName
    }
    
    private func filterContacts() {
        Task {
            await MainActor.run {
                if debouncedSearchText.isEmpty {
                    // When no search text, show suggested contacts and all contacts
                    suggestedContacts = getHighConfidenceSuggestions()
                    filteredContacts = deviceContacts.sorted { first, second in
                        let firstName = getDisplayName(first)
                        let secondName = getDisplayName(second)
                        return firstName.localizedCaseInsensitiveCompare(secondName) == .orderedAscending
                    }
                } else {
                    // When searching, hide suggestions and filter all contacts
                    suggestedContacts = []
                    filteredContacts = deviceContacts.filter { contact in
                        let fullName = "\(contact.givenName) \(contact.familyName)".lowercased()
                        let firstName = contact.givenName.lowercased()
                        let lastName = contact.familyName.lowercased()
                        let nickname = contact.nickname.lowercased()
                        let searchLower = debouncedSearchText.lowercased()
                        
                        return fullName.contains(searchLower) || 
                               firstName.contains(searchLower) || 
                               lastName.contains(searchLower) || 
                               nickname.contains(searchLower)
                    }
                }
            }
        }
    }
    
    private func hasValidName(_ contact: CNContact) -> Bool {
        // Check if contact has a nickname
        if !contact.nickname.isEmpty {
            return true
        }
        
        // Check if contact has a given name or family name
        let hasGivenName = !contact.givenName.isEmpty
        let hasFamilyName = !contact.familyName.isEmpty
        
        // Contact is valid if it has either a given name or family name
        return hasGivenName || hasFamilyName
    }
    
    private func hasCompleteBirthday(_ contact: CNContact) -> Bool {
        guard let birthday = contact.birthday else { return false }
        return birthday.year != nil && birthday.month != nil && birthday.day != nil
    }
    
    private func formatBirthday(_ birthday: DateComponents) -> String {
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let month = birthday.month ?? 0
        let day = birthday.day ?? 0
        let year = birthday.year ?? 0
        
        if year > 0 {
            let monthName = monthNames[month - 1]
            return "\(monthName) \(day), \(year)"
        } else {
            let monthName = monthNames[month - 1]
            return "\(monthName) \(day)"
        }
    }
    
    private func isContactAlreadyAdded(_ contact: CNContact) -> Bool {
        let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        let nickname = contact.nickname.isEmpty ? nil : contact.nickname
        
        // Use Set for faster lookups if we have many contacts
        let existingContacts = Set(contactManager.currentList?.contacts.map { $0.name } ?? [])
        
        // Quick check for full name match
        if existingContacts.contains(fullName) {
            // If there's a nickname, do a more detailed check
            if let nickname = nickname {
                return contactManager.currentList?.contacts.contains { existingContact in
                    existingContact.name == fullName && existingContact.nickname == nickname
                } ?? false
            } else {
                return contactManager.currentList?.contacts.contains { existingContact in
                    existingContact.name == fullName && existingContact.nickname == nil
                } ?? false
            }
        }
        
        return false
    }
    
    private func calculateFamilyScore(_ contact: CNContact) -> Int {
        let contactId = contact.identifier
        
        // Return cached score if available
        if let cachedScore = contactScores[contactId] {
            return cachedScore
        }
        
        var score = 0
        
        // Pre-compute strings once
        let fullName = "\(contact.givenName) \(contact.familyName)".lowercased()
        let nickname = contact.nickname.lowercased()
        
        // Use Set for faster lookups
        let familyKeywords = Set(["mom", "dad", "mother", "father", "parent", "child", "son", "daughter", "sister", "brother", "wife", "husband", "spouse", "grandma", "grandpa", "grandmother", "grandfather", "aunt", "uncle", "cousin", "family", "baby", "kid", "teen", "adult"])
        let familyNamePatterns = Set(["mom", "dad", "mama", "papa", "mommy", "daddy", "grandma", "grandpa", "nana", "papa"])
        
        // Check for family-related keywords
        for keyword in familyKeywords {
            if fullName.contains(keyword) {
                score += 15
            }
            if nickname.contains(keyword) {
                score += 12
            }
        }
        
        // Check for common family name patterns
        for pattern in familyNamePatterns {
            if fullName.contains(pattern) || nickname.contains(pattern) {
                score += 20
            }
        }
        
        // Quick property checks
        if contact.imageData != nil { score += 5 }
        if contact.phoneNumbers.count > 1 { score += 3 }
        if contact.emailAddresses.count > 0 { score += 2 }
        if !contact.organizationName.isEmpty { score -= 3 }
        if !contact.jobTitle.isEmpty { score -= 2 }
        if !contact.nickname.isEmpty { score += 3 }
        
        // Cache the score
        contactScores[contactId] = score
        return score
    }
    
    private func addContactToFamily(_ contact: CNContact) {
        // Check if contact has complete birthday
        if hasCompleteBirthday(contact) {
            let birthday = contact.birthday!
            
            // Create a Date from the birthday components
            let calendar = Calendar.current
            let date = calendar.date(from: DateComponents(year: birthday.year, month: birthday.month, day: birthday.day))!
            
            let newContact = contactManager.createContact(from: contact, birthday: date)
            contactManager.addContact(newContact)
            dismiss()
        } else {
            // Show birthday input for contacts with incomplete birthdays
            selectedContact = contact
            showingBirthdayInput = true
        }
    }
    
    private func handleBirthdaySelected(contact: CNContact, birthday: Date) async {
        // Save the birthday to the contact
        let success = await contactManager.saveBirthdayToContact(contact, birthday: birthday)
        
        await MainActor.run {
            if success {
                // Add the contact to family with the new birthday
                let newContact = contactManager.createContact(from: contact, birthday: birthday)
                contactManager.addContact(newContact)
                
                // Close the birthday input and contact picker
                showingBirthdayInput = false
                selectedContact = nil
                dismiss()
            } else {
                // Show error if saving failed
                errorMessage = "Failed to save birthday to contact. Please try again."
                showError = true
                showingBirthdayInput = false
                selectedContact = nil
            }
        }
    }
}

struct ContactPickerRow: View {
    let contact: CNContact
    let onTap: () -> Void
    let isAlreadyAdded: Bool
    @State private var isPressed = false
    
    private func hasCompleteBirthday(_ contact: CNContact) -> Bool {
        guard let birthday = contact.birthday else { return false }
        return birthday.year != nil && birthday.month != nil && birthday.day != nil
    }
    
    private func formatBirthday(_ birthday: DateComponents) -> String {
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let month = birthday.month ?? 0
        let day = birthday.day ?? 0
        let year = birthday.year ?? 0
        
        if year > 0 {
            let monthName = monthNames[month - 1]
            return "\(monthName) \(day), \(year)"
        } else {
            let monthName = monthNames[month - 1]
            return "\(monthName) \(day)"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if let imageData = contact.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        // Show nickname if available, otherwise show full name
                        if !contact.nickname.isEmpty {
                            Text(contact.nickname)
                                .font(.headline)
                                .foregroundColor(.primary)
                        } else {
                            Text("\(contact.givenName) \(contact.familyName)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        // Show full name in parentheses if nickname is being displayed
                        if !contact.nickname.isEmpty {
                            Text("(\(contact.givenName) \(contact.familyName))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if isAlreadyAdded {
                            Text("(Added)")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        if let birthday = contact.birthday {
                            HStack(spacing: 4) {
                                Text(formatBirthday(birthday))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if !hasCompleteBirthday(contact) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        if !contact.organizationName.isEmpty {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(contact.organizationName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isAlreadyAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: hasCompleteBirthday(contact) ? "plus.circle.fill" : "calendar.badge.plus")
                        .foregroundColor(hasCompleteBirthday(contact) ? .blue : .orange)
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPressed ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isAlreadyAdded)
        .opacity(isAlreadyAdded ? 0.6 : 1.0)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    ContactPicker(contactManager: ContactManager())
} 
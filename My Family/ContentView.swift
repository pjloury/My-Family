//
//  ContentView.swift
//  My Family
//
//  Created by PJ Loury on 7/26/25.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @StateObject var contactManager = ContactManager()
    @State private var showingContactPicker = false
    @State private var selectedContactForEdit: Contact?
    @State private var isEditingTitle = false
    @State private var editingTitle = ""
    @FocusState private var isTitleFieldFocused: Bool
    @State private var showingDeleteListAlert = false
    @State private var showingCalendarAlert = false
    @State private var showingCalendarPermissionAlert = false
    @State private var showingCalendarSuccessAlert = false
    @State private var calendarSuccessMessage = ""
    @State private var birthdayContact: Contact?
    @State private var isBreathing = false
    
    private var editingTitleBinding: Binding<String> {
        Binding(
            get: { editingTitle },
            set: { editingTitle = $0 }
        )
    }
    
    private var birthdayContactWithPhone: Contact? {
        guard let currentList = contactManager.currentList else { return nil }
        
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        
        return currentList.contacts.first { contact in
            let birthdayComponents = calendar.dateComponents([.month, .day], from: contact.birthday)
            return todayComponents.month == birthdayComponents.month && 
                   todayComponents.day == birthdayComponents.day &&
                   contact.phoneNumber != nil
        }
    }
    
    private func sendBirthdayMessage(to phoneNumber: String) {
        let message = "Happy birthday! 🎂"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedPhoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "sms:\(encodedPhoneNumber)&body=\(encodedMessage)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private var sortPickerView: some View {
        HStack {
            Text("Sort by:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker("Sort", selection: Binding(
                get: { contactManager.currentList?.selectedSortOption ?? .name },
                set: { contactManager.updateSortOption($0) }
            )) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.displayName).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: contactManager.currentList?.selectedSortOption) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.5)) {
                    contactManager.sortContacts()
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    contactManager.toggleSortDirection()
                }
            }) {
                Text(contactManager.currentList?.sortDirection.arrow ?? "⬆️")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
        private var birthdayPillButton: some View {
        Group {
            if let birthdayContact = birthdayContactWithPhone {
                Button(action: {
                    sendBirthdayMessage(to: birthdayContact.phoneNumber!)
                }) {
                    HStack(spacing: 8) {
                        Text("🎂")
                            .font(.title3)
                            .scaleEffect(isBreathing ? 1.15 : 0.9)
                            .animation(
                                Animation.easeInOut(duration: 1.2)
                                    .repeatForever(autoreverses: true)
                                    .delay(1.0),
                                value: isBreathing
                            )
                        
                        Text("Wish \(birthdayContact.firstName) a happy birthday")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.pink)
                    .cornerRadius(25)
                    .shadow(radius: 4)
                    .scaleEffect(isBreathing ? 1.03 : 0.97)
                    .animation(
                        Animation.easeInOut(duration: 1.2)
                                    .repeatForever(autoreverses: true)
                                    .delay(1.0),
                        value: isBreathing
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    // Start the breathing animation when the button appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isBreathing = true
                    }
                }
                .onDisappear {
                    // Stop the animation when the button disappears
                    isBreathing = false
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                sortPickerView
                ContactListView(contactManager: contactManager, selectedContactForEdit: $selectedContactForEdit)
                birthdayPillButton
                ContactListTabView(contactManager: contactManager)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        editingTitle = (contactManager.currentList?.title ?? "My Family")
                        isEditingTitle = true
                    }) {
                        ZStack {
                            Text(contactManager.currentList?.title ?? "My Family")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .id(contactManager.currentList?.title ?? "My Family")
                                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        }
                        .animation(.easeInOut(duration: 0.6), value: contactManager.currentList?.title)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingCalendarAlert = true
                        }) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        
                        Button(action: {
                            showingContactPicker = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(contactManager: contactManager)
            }
            .sheet(item: $selectedContactForEdit) { contact in
                ContactEditView(contact: contact, contactManager: contactManager)
            }
            .overlay(
                Group {
                    if isEditingTitle {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isEditingTitle = false
                            }
                        
                        VStack(spacing: 20) {
                            Text("Edit Title")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter title", text: editingTitleBinding)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .padding(.horizontal, 20)
                                .focused($isTitleFieldFocused)
                                .onChange(of: editingTitle) { oldValue, newValue in
                                    // Limit to 12 characters
                                    if newValue.count > 12 {
                                        editingTitle = String(newValue.prefix(12))
                                    }
                                }
                                .onAppear {
                                    // Focus the field when modal appears
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isTitleFieldFocused = true
                                    }
                                }
                            
                            HStack(spacing: 15) {
                                Button("Cancel") {
                                    isEditingTitle = false
                                }
                                .foregroundColor(.secondary)
                                
                                Button("Save") {
                                    if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        contactManager.updateCurrentListTitle(editingTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                                    }
                                    isEditingTitle = false
                                }
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            Button("Delete List") {
                                showingDeleteListAlert = true
                            }
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isEditingTitle)
            )
        }
        .navigationViewStyle(.stack)
        .onAppear {
            contactManager.sortContacts()
        }
        .animation(.easeInOut(duration: 0.3), value: birthdayContactWithPhone)
        .alert("Delete List", isPresented: $showingDeleteListAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                contactManager.deleteCurrentList()
                isEditingTitle = false
            }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
        .alert("Create Birthday Reminders", isPresented: $showingCalendarAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Create Events") {
                Task {
                    await createBirthdayCalendarEvents()
                }
            }
        } message: {
            Text("Would you like to create annual calendar event reminders for all birthdays in this list?")
        }
        .alert("Calendar Permission Required", isPresented: $showingCalendarPermissionAlert) {
            Button("OK") { }
        } message: {
            Text("Please grant calendar access in Settings to create birthday reminders.")
        }
        .overlay(
            Group {
                if showingCalendarSuccessAlert {
                    CalendarSuccessOverlay(message: calendarSuccessMessage, isPresented: $showingCalendarSuccessAlert)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showingCalendarSuccessAlert)
                }
            }
        )
    }
    
    private func createBirthdayCalendarEvents() {
        guard let currentList = contactManager.currentList else { return }
        
        let eventStore = EKEventStore()
        
        // Request calendar access
        Task {
            do {
                if #available(iOS 17.0, *) {
                    let granted = try await eventStore.requestFullAccessToEvents()
                    if granted {
                        await createEvents(for: currentList.contacts, using: eventStore)
                    } else {
                        await MainActor.run {
                            showingCalendarPermissionAlert = true
                        }
                    }
                } else {
                    // Fallback for iOS 16 and earlier
                    let granted = await withCheckedContinuation { continuation in
                        eventStore.requestAccess(to: .event) { granted, error in
                            continuation.resume(returning: granted)
                        }
                    }
                    
                    if granted {
                        await createEvents(for: currentList.contacts, using: eventStore)
                    } else {
                        await MainActor.run {
                            showingCalendarPermissionAlert = true
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    showingCalendarPermissionAlert = true
                }
            }
        }
    }
    
    private func createEvents(for contacts: [Contact], using eventStore: EKEventStore) async {
        // Get the default calendar
        guard let calendar = eventStore.defaultCalendarForNewEvents else { return }
        
        var createdCount = 0
        var skippedCount = 0
        
        for contact in contacts {
            // Check if a birthday event already exists for this contact
            if await eventExists(for: contact, in: eventStore, calendar: calendar) {
                skippedCount += 1
                continue
            }
                
                let event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
                event.title = "🎂 \(contact.name)'s Birthday"
                event.notes = "Birthday reminder for \(contact.name)"
                event.isAllDay = true
                
                // Set the birthday date (month and day only, year doesn't matter for recurring events)
                let calendar = Calendar.current
                let birthdayComponents = calendar.dateComponents([.month, .day], from: contact.birthday)
                let currentYear = calendar.component(.year, from: Date())
                
                // Create the event for this year
                if let eventDate = calendar.date(from: DateComponents(year: currentYear, month: birthdayComponents.month, day: birthdayComponents.day)) {
                    event.startDate = eventDate
                    event.endDate = eventDate // For all-day events, start and end should be the same date
                    
                    // Make it recurring annually
                    let recurrenceRule = EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil)
                    event.addRecurrenceRule(recurrenceRule)
                    
                    do {
                        try eventStore.save(event, span: .futureEvents)
                        createdCount += 1
                    } catch {
                        print("Failed to create calendar event for \(contact.name): \(error)")
                    }
                }
            }
            
            // Show results
            if createdCount > 0 || skippedCount > 0 {
                let message = createResultMessage(created: createdCount, skipped: skippedCount)
                await MainActor.run {
                    calendarSuccessMessage = message
                    showingCalendarSuccessAlert = true
                }
            }
    }
    
    private func eventExists(for contact: Contact, in eventStore: EKEventStore, calendar: EKCalendar) async -> Bool {
        let dateCalendar = Calendar.current
        let birthdayComponents = dateCalendar.dateComponents([.month, .day], from: contact.birthday)
        let currentYear = dateCalendar.component(.year, from: Date())
        
        // Create a date range to search for events (this year and next year to catch recurring events)
        guard let thisYearBirthday = dateCalendar.date(from: DateComponents(year: currentYear, month: birthdayComponents.month, day: birthdayComponents.day)),
              let nextYearBirthday = dateCalendar.date(from: DateComponents(year: currentYear + 1, month: birthdayComponents.month, day: birthdayComponents.day)) else {
            return false
        }
        
        // Search for events with the birthday title pattern
        let predicate = eventStore.predicateForEvents(withStart: thisYearBirthday, end: nextYearBirthday, calendars: [calendar])
        let events = eventStore.events(matching: predicate)
        
        // Check if any event matches the birthday pattern for this contact
        let birthdayTitle = "🎂 \(contact.name)'s Birthday"
        return events.contains { event in
            event.title == birthdayTitle && event.isAllDay
        }
    }
    
    private func createResultMessage(created: Int, skipped: Int) -> String {
        if created > 0 && skipped > 0 {
            let createdText = created == 1 ? "event" : "events"
            let skippedText = skipped == 1 ? "event" : "events"
            return "Created \(created) new birthday \(createdText). Skipped \(skipped) existing \(skippedText)."
        } else if created > 0 {
            let eventText = created == 1 ? "event" : "events"
            return "Successfully created \(created) birthday calendar \(eventText)."
        } else if skipped > 0 {
            let eventText = skipped == 1 ? "event" : "events"
            return "All \(skipped) birthday \(eventText) already exist in your calendar."
        } else {
            return "No birthday events were created."
        }
    }
}

struct ContactListView: View {
    @ObservedObject var contactManager: ContactManager
    @Binding var selectedContactForEdit: Contact?
    
    var body: some View {
        if let currentList = contactManager.currentList {
            if currentList.contacts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Build your Family")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Tap the + button to add contacts from your device")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            } else {
                List {
                    ForEach(currentList.contacts) { contact in
                        ContactRow(contact: contact) {
                            selectedContactForEdit = contact
                        }
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                    }
                    .onDelete(perform: contactManager.deleteContact)
                }
                .listStyle(PlainListStyle())
                .animation(.easeInOut(duration: 0.5), value: currentList.contacts.map { $0.id })
            }
        }
    }
}

struct CalendarSuccessOverlay: View {
    let message: String
    @State private var isAnimating = false
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Animated checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.6)
                    .repeatCount(1, autoreverses: false),
                    value: isAnimating
                )
            
            // Success message
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 60) // Account for navigation bar
        .onAppear {
            // Trigger animation when overlay appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
            
            // Auto-dismiss after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

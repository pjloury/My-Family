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
    @State private var showingNotificationPermission = false
    @State private var isNotificationMode = false
    @State private var showingTimingSettings = false
    @State private var isCalendarMode = false
    @State private var syncedContactIDs: Set<UUID> = []
    @State private var isCheckingCalendar = false
    @State private var isApplyingCalendar = false
    @State private var markedForRemovalIDs: Set<UUID> = []
    
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
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .layoutPriority(1)
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
    
    // MARK: - Calendar mode

    private var calendarModeBar: some View {
        let contacts = contactManager.currentList?.contacts ?? []
        let toAdd = contacts.filter { $0.calendarReminderEnabled && !syncedContactIDs.contains($0.id) }
        let toRemove = contacts.filter { markedForRemovalIDs.contains($0.id) }
        let syncedKept = contacts.filter { syncedContactIDs.contains($0.id) && !markedForRemovalIDs.contains($0.id) }
        let excluded = contacts.filter { !$0.calendarReminderEnabled && !syncedContactIDs.contains($0.id) }
        let hasPendingChanges = !toAdd.isEmpty || !toRemove.isEmpty

        return HStack(spacing: 10) {
            // Status chips
            if isCheckingCalendar {
                ProgressView().scaleEffect(0.7)
                Text("Checking…").font(.caption).foregroundColor(.secondary)
            } else {
                if syncedKept.count > 0 {
                    Label("\(syncedKept.count)", systemImage: "checkmark.circle.fill")
                        .font(.caption2).foregroundColor(.green)
                }
                if toAdd.count > 0 {
                    Label("+\(toAdd.count)", systemImage: "calendar.badge.plus")
                        .font(.caption2).foregroundColor(.blue)
                }
                if toRemove.count > 0 {
                    Label("−\(toRemove.count)", systemImage: "calendar.badge.minus")
                        .font(.caption2).foregroundColor(.red)
                }
                if excluded.count > 0 {
                    Label("\(excluded.count)", systemImage: "minus.circle")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }

            Spacer()

            // Select all / deselect all (only non-synced contacts)
            let unsyncedContacts = contacts.filter { !syncedContactIDs.contains($0.id) }
            if !unsyncedContacts.isEmpty {
                let allEnabled = unsyncedContacts.allSatisfy { $0.calendarReminderEnabled }
                Button(allEnabled ? "Deselect All" : "Select All") {
                    let newValue = !allEnabled
                    for i in contactManager.contactLists[contactManager.selectedListIndex].contacts.indices {
                        let id = contactManager.contactLists[contactManager.selectedListIndex].contacts[i].id
                        if !syncedContactIDs.contains(id) {
                            contactManager.contactLists[contactManager.selectedListIndex].contacts[i].calendarReminderEnabled = newValue
                        }
                    }
                    contactManager.saveContactLists()
                }
                .font(.caption)
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }

            // Apply button
            Button(action: { applyCalendarChanges() }) {
                if isApplyingCalendar {
                    ProgressView().scaleEffect(0.7).frame(width: 72, height: 30)
                } else {
                    Text(hasPendingChanges ? "Apply" : "Up to Date")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Capsule().fill(hasPendingChanges ? Color.green : Color.secondary.opacity(0.5)))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!hasPendingChanges || isApplyingCalendar)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.08))
    }

    private func enterCalendarMode() {
        isCalendarMode = true
        isCheckingCalendar = true
        syncedContactIDs = []
        markedForRemovalIDs = []
        Task {
            let ids = await checkSyncedContacts()
            await MainActor.run {
                syncedContactIDs = ids
                isCheckingCalendar = false
            }
        }
    }

    private func checkSyncedContacts() async -> Set<UUID> {
        guard let contacts = contactManager.currentList?.contacts, !contacts.isEmpty else { return [] }
        let eventStore = EKEventStore()
        guard let granted = try? await requestCalendarAccess(eventStore: eventStore), granted else { return [] }
        guard let cal = eventStore.defaultCalendarForNewEvents else { return [] }
        var synced = Set<UUID>()
        for contact in contacts {
            if await eventExists(for: contact, in: eventStore, calendar: cal) {
                synced.insert(contact.id)
            }
        }
        return synced
    }

    private func requestCalendarAccess(eventStore: EKEventStore) async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return await withCheckedContinuation { cont in
                eventStore.requestAccess(to: .event) { g, _ in cont.resume(returning: g) }
            }
        }
    }

    private func applyCalendarChanges() {
        guard let contacts = contactManager.currentList?.contacts else { return }
        let toAdd = contacts.filter { $0.calendarReminderEnabled && !syncedContactIDs.contains($0.id) }
        let toRemove = contacts.filter { markedForRemovalIDs.contains($0.id) }
        guard !toAdd.isEmpty || !toRemove.isEmpty else { return }
        isApplyingCalendar = true
        Task {
            let eventStore = EKEventStore()
            guard let granted = try? await requestCalendarAccess(eventStore: eventStore), granted else {
                await MainActor.run { isApplyingCalendar = false; showingCalendarPermissionAlert = true }
                return
            }
            if !toAdd.isEmpty { await createEvents(for: toAdd, using: eventStore) }
            if !toRemove.isEmpty { await removeCalendarEvents(for: toRemove, using: eventStore) }
            let ids = await checkSyncedContacts()
            await MainActor.run {
                syncedContactIDs = ids
                markedForRemovalIDs = []
                isApplyingCalendar = false
            }
        }
    }

    private func removeCalendarEvents(for contacts: [Contact], using eventStore: EKEventStore) async {
        guard let cal = eventStore.defaultCalendarForNewEvents else { return }
        let dateCalendar = Calendar.current
        let currentYear = dateCalendar.component(.year, from: Date())
        for contact in contacts {
            let title = "🎂 \(contact.name)'s Birthday"
            let components = dateCalendar.dateComponents([.month, .day], from: contact.birthday)
            guard let start = dateCalendar.date(from: DateComponents(year: currentYear, month: components.month, day: components.day)),
                  let end = dateCalendar.date(from: DateComponents(year: currentYear + 1, month: components.month, day: components.day))
            else { continue }
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: [cal])
            let matches = eventStore.events(matching: predicate).filter { $0.title == title && $0.isAllDay }
            for event in matches {
                try? eventStore.remove(event, span: .futureEvents)
            }
        }
    }

    private var notificationModeBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                guard let list = contactManager.currentList else { return }
                let allEnabled = list.contacts.allSatisfy { $0.notificationsEnabled }
                for i in contactManager.contactLists[contactManager.selectedListIndex].contacts.indices {
                    contactManager.contactLists[contactManager.selectedListIndex].contacts[i].notificationsEnabled = !allEnabled
                }
                contactManager.saveContactLists()
            }) {
                let allEnabled = contactManager.currentList?.contacts.allSatisfy { $0.notificationsEnabled } ?? false
                Label(allEnabled ? "Disable All" : "Enable All",
                      systemImage: allEnabled ? "bell.slash" : "bell.badge")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.blue))
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: { showingTimingSettings = true }) {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.08))
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
                if contactManager.isSpecialDatesSelected {
                    SpecialDatesListView(contactManager: contactManager, selectedContactForEdit: $selectedContactForEdit)
                } else {
                    if isNotificationMode {
                        notificationModeBar
                    } else if isCalendarMode {
                        calendarModeBar
                    } else {
                        sortPickerView
                    }
                    ContactListView(
                        contactManager: contactManager,
                        selectedContactForEdit: $selectedContactForEdit,
                        isNotificationMode: isNotificationMode,
                        isCalendarMode: isCalendarMode,
                        syncedContactIDs: syncedContactIDs,
                        markedForRemovalIDs: markedForRemovalIDs,
                        onToggleCalendar: { contact in
                            if syncedContactIDs.contains(contact.id) {
                                if markedForRemovalIDs.contains(contact.id) {
                                    markedForRemovalIDs.remove(contact.id)
                                } else {
                                    markedForRemovalIDs.insert(contact.id)
                                }
                            } else {
                                guard let idx = contactManager.contactLists[contactManager.selectedListIndex]
                                    .contacts.firstIndex(where: { $0.id == contact.id }) else { return }
                                contactManager.contactLists[contactManager.selectedListIndex].contacts[idx].calendarReminderEnabled.toggle()
                                contactManager.saveContactLists()
                            }
                        }
                    )
                    if !isNotificationMode && !isCalendarMode {
                        birthdayPillButton
                    }
                }
                ContactListTabView(contactManager: contactManager)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Check and schedule notifications when app becomes active (only if enabled)
                if ContactManager.notificationsEnabled {
                    NotificationManager.shared.checkAndScheduleNotifications(for: contactManager)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if contactManager.isSpecialDatesSelected {
                        Text("Special Dates")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    } else {
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
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Plus — hidden in any mode but kept in layout to prevent icon shift
                        Button(action: { showingContactPicker = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        .opacity(isNotificationMode || isCalendarMode ? 0 : 1)
                        .allowsHitTesting(!isNotificationMode && !isCalendarMode)

                        // Calendar mode toggle — same icon always, tinted blue when active
                        Button(action: {
                            if isCalendarMode {
                                isCalendarMode = false
                                syncedContactIDs = []
                                markedForRemovalIDs = []
                            } else {
                                isNotificationMode = false
                                enterCalendarMode()
                            }
                        }) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(isCalendarMode ? .blue : .primary)
                        }

                        // Notification mode toggle — dimmed (not hidden) when in calendar mode
                        if ContactManager.notificationsEnabled {
                            Button(action: {
                                guard !isCalendarMode else { return }
                                if isNotificationMode {
                                    isNotificationMode = false
                                } else {
                                    isNotificationMode = true
                                }
                            }) {
                                Image(systemName: isNotificationMode ? "bell.fill" : "bell")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(
                                        isCalendarMode ? .secondary.opacity(0.4) :
                                        isNotificationMode ? .blue : .primary
                                    )
                            }
                        }
                        
                        // Notification buttons (only shown when notifications are enabled and dev mode is on)
                        if ContactManager.notificationsEnabled && ContactManager.devModeEnabled {
                            Button(action: {
                                // Manually trigger notification scheduling for testing
                                NotificationManager.shared.checkAndScheduleNotifications(for: contactManager)
                            }) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            Button(action: {
                                // Test notification with first contact
                                print("🔔 Bell badge button tapped")
                                
                                if let firstContact = contactManager.currentList?.contacts.first {
                                    print("📱 Found contact: \(firstContact.name)")
                                    NotificationManager.shared.scheduleTestNotification(for: firstContact)
                                } else {
                                    print("❌ No contacts found in current list")
                                    // Create a test contact if none exist
                                    let testContact = Contact(
                                        name: "Test User",
                                        firstName: "Test",
                                        nickname: nil,
                                        birthday: Date(),
                                        photoFileName: nil,
                                        phoneNumber: nil
                                    )
                                    print("🧪 Using test contact: \(testContact.name)")
                                    NotificationManager.shared.scheduleTestNotification(for: testContact)
                                }
                            }) {
                                Image(systemName: "bell.badge")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            Button(action: {
                                // Test immediate notification
                                print("⚡ Immediate notification button tapped")
                                
                                if let firstContact = contactManager.currentList?.contacts.first {
                                    print("📱 Found contact: \(firstContact.name)")
                                    NotificationManager.shared.showImmediateTestNotification(for: firstContact)
                                } else {
                                    print("❌ No contacts found in current list")
                                    // Create a test contact if none exist
                                    let testContact = Contact(
                                        name: "Test User",
                                        firstName: "Test",
                                        nickname: nil,
                                        birthday: Date(),
                                        photoFileName: nil,
                                        phoneNumber: nil
                                    )
                                    print("🧪 Using test contact: \(testContact.name)")
                                    NotificationManager.shared.showImmediateTestNotification(for: testContact)
                                }
                            }) {
                                Image(systemName: "bolt.fill")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            Button(action: {
                                // Show notification permission modal
                                showingNotificationPermission = true
                            }) {
                                Image(systemName: "bell.slash")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
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
            .sheet(isPresented: $showingTimingSettings) {
                NotificationTimingSettingsView(isPresented: $showingTimingSettings)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingNotificationPermission) {
                if ContactManager.notificationsEnabled {
                    NotificationPermissionView(
                        isPresented: $showingNotificationPermission,
                        onPermissionRequested: {
                            Task {
                                let granted = await NotificationManager.shared.requestNotificationPermission()
                                if granted {
                                    print("Notification permission granted")
                                } else {
                                    print("Notification permission denied")
                                }
                            }
                        }
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
                }
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
    var isNotificationMode: Bool = false
    var isCalendarMode: Bool = false
    var syncedContactIDs: Set<UUID> = []
    var markedForRemovalIDs: Set<UUID> = []
    var onToggleCalendar: ((Contact) -> Void)? = nil

    private var isAnyMode: Bool { isNotificationMode || isCalendarMode }

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
                        ContactRow(
                            contact: contact,
                            onTap: {
                                if !isAnyMode { selectedContactForEdit = contact }
                            },
                            isNotificationMode: isNotificationMode,
                            onToggleNotification: {
                                guard let idx = contactManager.contactLists[contactManager.selectedListIndex]
                                    .contacts.firstIndex(where: { $0.id == contact.id }) else { return }
                                contactManager.contactLists[contactManager.selectedListIndex].contacts[idx].notificationsEnabled.toggle()
                                contactManager.saveContactLists()
                            },
                            isCalendarMode: isCalendarMode,
                            calendarStatus: {
                                if syncedContactIDs.contains(contact.id) {
                                    return markedForRemovalIDs.contains(contact.id) ? .markedForRemoval : .synced
                                }
                                return contact.calendarReminderEnabled ? .pending : .excluded
                            }(),
                            onToggleCalendar: {
                                onToggleCalendar?(contact)
                            }
                        )
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                    }
                    .onDelete(perform: isAnyMode ? nil : contactManager.deleteContact)
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

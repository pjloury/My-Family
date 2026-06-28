//
//  My_FamilyApp.swift
//  My Family
//
//  Created by PJ Loury on 7/26/25.
//

import SwiftUI
import UserNotifications

extension Notification.Name {
    static let startBirthdayActivity = Notification.Name("startBirthdayActivity")
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        print("🔔 Notification delegate called - willPresent: \(notification.request.identifier)")
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Notification tapped: \(response.notification.request.identifier)")
        // Start Live Activity on birthday notification tap
        if #available(iOS 16.2, *),
           response.notification.request.identifier.contains("_0days") {
            let contactId = response.notification.request.identifier
                .replacingOccurrences(of: "birthday_", with: "")
                .replacingOccurrences(of: "_0days", with: "")
            NotificationCenter.default.post(name: .startBirthdayActivity, object: contactId)
        }
        completionHandler()
    }
}

@main
struct My_FamilyApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingNotificationPermission = false
    @State private var hasShownPermissionModal = false
    private let notificationDelegate = NotificationDelegate()
    
    init() {
        #if DEBUG
        MockDataLoader.injectIfNeeded()
        #endif
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    checkNotificationPermission()
                    startLiveActivityIfBirthday()
                }
                .onReceive(NotificationCenter.default.publisher(for: .startBirthdayActivity)) { note in
                    if #available(iOS 16.2, *), let contactId = note.object as? String {
                        let contactManager = ContactManager()
                        let all = contactManager.contactLists.flatMap { $0.contacts }
                        if let contact = all.first(where: { $0.id.uuidString == contactId }) {
                            BirthdayActivityManager.shared.start(for: contact)
                        }
                    }
                }
                .sheet(isPresented: $showingNotificationPermission) {
                    NotificationPermissionView(
                        isPresented: $showingNotificationPermission,
                        onPermissionRequested: {
                            requestNotificationPermission()
                        }
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled()
                }
        }
    }
    
    private func startLiveActivityIfBirthday() {
        guard #available(iOS 16.2, *) else { return }
        let contactManager = ContactManager()
        let all = contactManager.contactLists.flatMap { $0.contacts }
        BirthdayActivityManager.shared.startIfBirthday(for: all)
    }

    private func checkNotificationPermission() {
        // SCREENSHOT MODE: skip notification modal
        #if DEBUG
        if ProcessInfo.processInfo.environment["SCREENSHOT_MODE"] == "1" { return }
        #endif
        // Only check notification permissions if notifications are enabled
        guard ContactManager.notificationsEnabled else { return }
        
        // Check if we've already shown the permission modal
        let hasShown = UserDefaults.standard.bool(forKey: "hasShownNotificationPermissionModal")
        
        if !hasShown {
            // Show the permission modal first
            showingNotificationPermission = true
            UserDefaults.standard.set(true, forKey: "hasShownNotificationPermissionModal")
        } else {
            // Check if we already have permission
            Task {
                let center = UNUserNotificationCenter.current()
                let settings = await center.notificationSettings()
                
                if settings.authorizationStatus == .notDetermined {
                    // Show the permission modal again
                    await MainActor.run {
                        showingNotificationPermission = true
                    }
                }
            }
        }
    }
    
    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        print("🔔 Notification delegate set successfully")
        
        // Create notification category with actions
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: [.destructive]
        )
        
        let birthdayCategory = UNNotificationCategory(
            identifier: "BIRTHDAY_REMINDER",
            actions: [dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([birthdayCategory])
        print("🔔 Notification categories set successfully")
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationManager.requestNotificationPermission()
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}

import SwiftUI

enum CalendarSyncStatus {
    case synced          // green: event exists, tap to mark for removal
    case markedForRemoval // red: will be removed on apply
    case pending         // blue: will be created on apply
    case excluded        // gray: user opted out
}

struct ContactRow: View {
    let contact: Contact
    let onTap: () -> Void
    var isNotificationMode: Bool = false
    var onToggleNotification: (() -> Void)? = nil
    var isCalendarMode: Bool = false
    var calendarStatus: CalendarSyncStatus = .pending
    var onToggleCalendar: (() -> Void)? = nil
    @State private var showingHoroscopePopup = false
    @State private var showingChineseZodiacPopup = false
    @State private var showingBirthdayPopup = false
    @State private var isAnimating = false
    
    private var isBirthdayToday: Bool {
        let calendar = Calendar.current
        let today = Date()
        let birthday = contact.birthday
        
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        return todayComponents.month == birthdayComponents.month && 
               todayComponents.day == birthdayComponents.day
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Contact Photo
                ZStack(alignment: .bottomTrailing) {
                    if let photo = contact.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .grayscale(0)
                            .opacity(contact.isDeceased ? 0.75 : 1)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(contact.isDeceased ? .gray.opacity(0.5) : .gray)
                    }
                    if contact.isDeceased {
                        Text("🕊")
                            .font(.system(size: 14))
                            .offset(x: 4, y: 4)
                    }
                }

                // Contact Info - Left side (Name and Age)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundColor(contact.isDeceased ? .secondary : .primary)
                        if contact.isDeceased {
                            if let ageAtDeath = contact.ageAtDeath {
                                Text("• \(ageAtDeath)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("• \(contact.age)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    

                    HStack(spacing: 4) {
                        Button(action: {
                            showingBirthdayPopup = true
                        }) {
                            Text(contact.birthdayMonthDay)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingHoroscopePopup = true
                        }) {
                            Text(contact.zodiacSign)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            showingChineseZodiacPopup = true
                        }) {
                            Text(contact.chineseZodiacAnimal)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if let gradeEmoji = contact.gradeLevelEmoji {
                            Text(gradeEmoji)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Time Info - Right side
                if isNotificationMode {
                    Button(action: { onToggleNotification?() }) {
                        Image(systemName: contact.notificationsEnabled ? "bell.fill" : "bell.slash")
                            .font(.title3)
                            .foregroundColor(contact.notificationsEnabled ? .blue : .secondary.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if isCalendarMode {
                    Button(action: { onToggleCalendar?() }) {
                        VStack(spacing: 3) {
                            switch calendarStatus {
                            case .synced:
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.green)
                                Text("Synced")
                                    .font(.system(size: 9))
                                    .foregroundColor(.green)
                            case .markedForRemoval:
                                Image(systemName: "calendar.badge.minus")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                Text("Remove")
                                    .font(.system(size: 9))
                                    .foregroundColor(.red)
                            case .pending:
                                Image(systemName: "calendar.badge.plus")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text("To Add")
                                    .font(.system(size: 9))
                                    .foregroundColor(.blue)
                            case .excluded:
                                Image(systemName: "minus.circle")
                                    .font(.title3)
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("Skipped")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    VStack(alignment: .trailing, spacing: 2) {
                        if contact.isDeceased {
                            if isBirthdayToday {
                                VStack(spacing: 2) {
                                    Text("🕊")
                                        .font(.title2)
                                    Text("Would be \(contact.wouldBeAge)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.trailing)
                                }
                            } else {
                                Text(contact.monthsUntilBirthday)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text("would be \(contact.wouldBeAge + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if isBirthdayToday {
                            if contact.phoneNumber != nil {
                                Button(action: {
                                    sendBirthdayMessage(to: contact.phoneNumber!)
                                }) {
                                    VStack(spacing: 2) {
                                        Text("🎂")
                                            .font(.title2)
                                            .scaleEffect(isAnimating ? 1.15 : 0.9)
                                            .animation(
                                                Animation.easeInOut(duration: 1.2)
                                                    .repeatForever(autoreverses: true)
                                                    .delay(1.0),
                                                value: isAnimating
                                            )
                                        Text("BIRTHDAY!")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.pink)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help("Tap to wish them a happy birthday")
                            } else {
                                VStack(spacing: 2) {
                                    Text("🎂")
                                        .font(.title2)
                                        .scaleEffect(isAnimating ? 1.15 : 0.9)
                                        .animation(
                                            Animation.easeInOut(duration: 1.2)
                                                .repeatForever(autoreverses: true)
                                                .delay(1.0),
                                            value: isAnimating
                                        )
                                    Text("BIRTHDAY!")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.pink)
                                }
                            }
                        } else {
                            Text(contact.monthsUntilBirthday)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("til next b-day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .id(contact.id) // Force refresh when contact changes
        .onAppear {
            if isBirthdayToday {
                // Start animation with same delay as floating button
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = true
                }
            }
        }
        .onDisappear {
            // Stop animation when row disappears
            isAnimating = false
        }
        .sheet(isPresented: $showingHoroscopePopup) {
            HoroscopePopupView(zodiacSign: contact.zodiacSign, contactName: contact.name)
        }
        .sheet(isPresented: $showingChineseZodiacPopup) {
            ChineseZodiacPopupView(chineseZodiacAnimal: contact.chineseZodiacAnimal, contactName: contact.name)
        }
        .sheet(isPresented: $showingBirthdayPopup) {
            BirthdayPopupView(birthday: contact.birthday, contactName: contact.name)
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
}

#Preview {
    ContactRow(
        contact: Contact(
            name: "John Doe", firstName: "John",
            nickname: nil,
            birthday: Date().addingTimeInterval(-30*365*24*60*60), // 30 years ago
            photoFileName: nil
        ),
        onTap: {}
    )
    .padding()
} 

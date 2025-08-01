import SwiftUI

struct ContactRow: View {
    let contact: Contact
    let onTap: () -> Void
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
                if let photo = contact.photo {
                    Image(uiImage: photo)
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
                
                // Contact Info - Left side (Name and Age)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(contact.name) • \(contact.age)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Button(action: {
                            showingBirthdayPopup = true
                        }) {
                            Text(contact.birthdayString)
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
                VStack(alignment: .trailing, spacing: 2) {
                    if isBirthdayToday {
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

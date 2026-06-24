import SwiftUI

enum DetailTab: Int, CaseIterable {
    case profile, birthday, horoscope, zodiac

    var label: String {
        switch self {
        case .profile:   return "Profile"
        case .birthday:  return "This Day"
        case .horoscope: return "Horoscope"
        case .zodiac:    return "Lunar"
        }
    }

    var icon: String {
        switch self {
        case .profile:   return "person.fill"
        case .birthday:  return "clock.fill"
        case .horoscope: return "sparkles"
        case .zodiac:    return "moon.stars.fill"
        }
    }
}

struct ContactDetailView: View {
    let contact: Contact
    @ObservedObject var contactManager: ContactManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .profile
    @State private var saveNow = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab bar
                HStack(spacing: 0) {
                    ForEach(DetailTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 16, weight: .medium))
                                Text(tab.label)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(selectedTab == tab ? .blue : .secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.blue.opacity(0.08) : Color.clear)
                            )
                            .overlay(
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.blue : Color.clear)
                                    .frame(height: 2),
                                alignment: .bottom
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color(.systemBackground))

                Divider()

                // Paged content
                TabView(selection: $selectedTab) {
                    ContactEditView(contact: contact, contactManager: contactManager, embedded: true, shouldSave: $saveNow)
                        .tag(DetailTab.profile)

                    BirthdayPopupView(birthday: contact.birthday, contactName: contact.name, embedded: true)
                        .tag(DetailTab.birthday)

                    HoroscopePopupView(zodiacSign: contact.zodiacSign, contactName: contact.name, embedded: true)
                        .tag(DetailTab.horoscope)

                    ChineseZodiacPopupView(chineseZodiacAnimal: contact.chineseZodiacAnimal, contactName: contact.name, embedded: true)
                        .tag(DetailTab.zodiac)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
            .navigationTitle(contact.firstName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveNow = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { dismiss() }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

}

#Preview {
    ContactDetailView(
        contact: Contact(
            name: "Jane Doe", firstName: "Jane",
            nickname: nil,
            birthday: Calendar.current.date(byAdding: .year, value: -35, to: Date())!,
            photoFileName: nil
        ),
        contactManager: ContactManager()
    )
}

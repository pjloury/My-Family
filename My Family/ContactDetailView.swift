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
    @State private var showingEdit = false

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
                    profilePage
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { showingEdit = true }
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingEdit) {
            ContactEditView(contact: contact, contactManager: contactManager)
        }
    }

    private var profilePage: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Photo + name
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        if let photo = contact.photo {
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        if contact.isDeceased {
                            Text("🕊")
                                .font(.system(size: 22))
                                .offset(x: 4, y: 4)
                        }
                    }

                    Text(contact.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let relation = contact.relation {
                        Text(relation.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.secondary.opacity(0.12)))
                    }
                }
                .padding(.top, 24)

                // Stats
                HStack(spacing: 0) {
                    statCell(title: contact.isDeceased ? "Age at Death" : "Age",
                             value: contact.isDeceased
                                ? (contact.ageAtDeath.map { "\($0)" } ?? "—")
                                : "\(contact.age)")
                    Divider().frame(height: 40)
                    statCell(title: "Birthday", value: contact.birthdayMonthDay)
                    Divider().frame(height: 40)
                    statCell(title: "Next", value: contact.monthsUntilBirthday)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Signs row
                HStack(spacing: 0) {
                    statCell(title: "Western", value: contact.zodiacSign)
                    Divider().frame(height: 40)
                    statCell(title: "Lunar", value: contact.chineseZodiacAnimal)
                    if let grade = contact.gradeLevelEmoji {
                        Divider().frame(height: 40)
                        statCell(title: "Grade", value: grade)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                // Special dates
                if !contact.specialDates.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Special Dates")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(contact.specialDates) { sd in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sd.displayLabel)
                                        .font(.subheadline)
                                    Text(formattedDate(sd.date))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(sd.monthsUntilNext)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d"
        return f.string(from: date)
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

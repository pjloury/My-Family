import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entries

struct MultiBirthdayEntry: TimelineEntry {
    let date: Date
    let contacts: [WidgetContactData]
    let page: Int
    let family: String
}

struct SingleBirthdayEntry: TimelineEntry {
    let date: Date
    let contact: WidgetContactData?
}

// MARK: - Providers

struct MediumBirthdayProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultiBirthdayEntry {
        MultiBirthdayEntry(date: Date(), contacts: [], page: 1, family: "medium")
    }
    func getSnapshot(in context: Context, completion: @escaping (MultiBirthdayEntry) -> Void) {
        let page = UserDefaults(suiteName: widgetAppGroupID)?.integer(forKey: mediumPageKey) ?? 1
        completion(MultiBirthdayEntry(date: Date(), contacts: loadAllWidgetContacts(), page: max(page, 1), family: "medium"))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MultiBirthdayEntry>) -> Void) {
        let page = UserDefaults(suiteName: widgetAppGroupID)?.integer(forKey: mediumPageKey) ?? 1
        let entry = MultiBirthdayEntry(date: Date(), contacts: loadAllWidgetContacts(), page: max(page, 1), family: "medium")
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct LargeBirthdayProvider: TimelineProvider {
    func placeholder(in context: Context) -> MultiBirthdayEntry {
        MultiBirthdayEntry(date: Date(), contacts: [], page: 1, family: "large")
    }
    func getSnapshot(in context: Context, completion: @escaping (MultiBirthdayEntry) -> Void) {
        let page = UserDefaults(suiteName: widgetAppGroupID)?.integer(forKey: largePageKey) ?? 1
        completion(MultiBirthdayEntry(date: Date(), contacts: loadAllWidgetContacts(), page: max(page, 1), family: "large"))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MultiBirthdayEntry>) -> Void) {
        let page = UserDefaults(suiteName: widgetAppGroupID)?.integer(forKey: largePageKey) ?? 1
        let entry = MultiBirthdayEntry(date: Date(), contacts: loadAllWidgetContacts(), page: max(page, 1), family: "large")
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

struct SingleBirthdayProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SingleBirthdayEntry {
        SingleBirthdayEntry(date: Date(), contact: nil)
    }
    func snapshot(for configuration: SelectContactIntent, in context: Context) async -> SingleBirthdayEntry {
        SingleBirthdayEntry(date: Date(), contact: resolveContact(from: configuration))
    }
    func timeline(for configuration: SelectContactIntent, in context: Context) async -> Timeline<SingleBirthdayEntry> {
        let entry = SingleBirthdayEntry(date: Date(), contact: resolveContact(from: configuration))
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        return Timeline(entries: [entry], policy: .after(midnight))
    }
    private func resolveContact(from config: SelectContactIntent) -> WidgetContactData? {
        let all = loadAllWidgetContacts()
        guard let selectedID = config.contact?.id else { return all.first }
        return all.first { $0.id.uuidString == selectedID } ?? all.first
    }
}

// MARK: - Avatar helper

private func avatarColor(for name: String) -> Color {
    let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo]
    return colors[abs(name.hashValue) % colors.count]
}

// MARK: - Avatar view (photo or colored initial)

struct ContactAvatarView: View {
    let contact: WidgetContactData
    let size: CGFloat

    var body: some View {
        if let photo = contact.photoImage {
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(avatarColor(for: contact.displayName))
                    .frame(width: size, height: size)
                Text(String(contact.displayName.prefix(1)).uppercased())
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Small Widget View

struct SmallBirthdayWidgetView: View {
    let contact: WidgetContactData?

    var body: some View {
        if let contact {
            VStack(spacing: 8) {
                ContactAvatarView(contact: contact, size: 52)
                Text(contact.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(contact.birthdayMonthDay)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text(contact.daysLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(contact.daysUntilNextBirthday == 0 ? .pink : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(
                        contact.daysUntilNextBirthday == 0 ? Color.pink.opacity(0.15) : Color.blue.opacity(0.12)
                    ))
            }
            .padding(12)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "birthday.cake")
                    .font(.system(size: 30))
                    .foregroundColor(.pink)
                Text("No contacts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Birthday Row

struct BirthdayRowView: View {
    let contact: WidgetContactData
    let compact: Bool

    var body: some View {
        HStack(spacing: 10) {
            ContactAvatarView(contact: contact, size: compact ? 30 : 36)
            Text(contact.displayName)
                .font(.system(size: compact ? 13 : 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            Text("·")
                .foregroundColor(.secondary)
                .font(.system(size: compact ? 12 : 13))
            Text(contact.birthdayMonthDay)
                .font(.system(size: compact ? 12 : 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(contact.daysLabel)
                .font(.system(size: compact ? 11 : 12, weight: .medium))
                .foregroundColor(contact.daysUntilNextBirthday == 0 ? .pink : .blue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(
                    contact.daysUntilNextBirthday == 0 ? Color.pink.opacity(0.15) : Color.blue.opacity(0.12)
                ))
                .fixedSize()
        }
    }
}

// MARK: - Paged Birthday Widget View

struct PagedBirthdayWidgetView: View {
    let entry: MultiBirthdayEntry
    let compact: Bool

    private var pageSize: Int { compact ? 3 : 6 }

    private var pagedContacts: [WidgetContactData] {
        let start = (entry.page - 1) * pageSize
        guard start < entry.contacts.count else { return [] }
        return Array(entry.contacts[start..<min(start + pageSize, entry.contacts.count)])
    }

    private var totalPages: Int {
        max(1, Int(ceil(Double(entry.contacts.count) / Double(pageSize))))
    }

    private var prevIntent: PrevPageIntent {
        var i = PrevPageIntent()
        i.family = entry.family
        return i
    }

    private var nextIntent: NextPageIntent {
        var i = NextPageIntent()
        i.family = entry.family
        i.pageSize = pageSize
        return i
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            // Header with prev/next buttons
            HStack(spacing: 4) {
                Text("🎂 Upcoming Birthdays")
                    .font(.system(size: compact ? 13 : 15, weight: compact ? .semibold : .bold))
                    .foregroundColor(compact ? .secondary : .primary)
                    .lineLimit(1)

                Spacer()

                if totalPages > 1 {
                    Button(intent: prevIntent) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(entry.page > 1 ? .blue : .secondary.opacity(0.4))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.blue.opacity(entry.page > 1 ? 0.1 : 0.04)))
                    }
                    .buttonStyle(.plain)
                    .disabled(entry.page <= 1)

                    Text("\(entry.page)/\(totalPages)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(minWidth: 28)

                    Button(intent: nextIntent) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(entry.page < totalPages ? .blue : .secondary.opacity(0.4))
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.blue.opacity(entry.page < totalPages ? 0.1 : 0.04)))
                    }
                    .buttonStyle(.plain)
                    .disabled(entry.page >= totalPages)
                }
            }

            if pagedContacts.isEmpty {
                Spacer()
                Text(entry.contacts.isEmpty ? "Add contacts in Fam List" : "No more birthdays")
                    .font(compact ? .caption : .body)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ForEach(Array(pagedContacts.enumerated()), id: \.element.id) { index, contact in
                    BirthdayRowView(contact: contact, compact: compact)
                    if index < pagedContacts.count - 1 {
                        Divider()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(compact ? 14 : 16)
    }
}

// MARK: - Widget Definitions

struct MediumFamilyBirthdayWidget: Widget {
    let kind = "FamilyBirthdayWidgetMedium"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediumBirthdayProvider()) { entry in
            PagedBirthdayWidgetView(entry: entry, compact: true)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Family Birthdays")
        .description("Tap ‹ › to page through upcoming birthdays.")
        .supportedFamilies([.systemMedium])
    }
}

struct LargeFamilyBirthdayWidget: Widget {
    let kind = "FamilyBirthdayWidgetLarge"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeBirthdayProvider()) { entry in
            PagedBirthdayWidgetView(entry: entry, compact: false)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Family Birthdays (Large)")
        .description("Tap ‹ › to page through upcoming birthdays.")
        .supportedFamilies([.systemLarge])
    }
}

struct SingleContactBirthdayWidget: Widget {
    let kind = "SingleContactBirthdayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectContactIntent.self, provider: SingleBirthdayProvider()) { entry in
            SmallBirthdayWidgetView(contact: entry.contact)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Single Birthday")
        .description("Track one family member's birthday.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Widget Bundle

@main
struct FamilyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MediumFamilyBirthdayWidget()
        LargeFamilyBirthdayWidget()
        SingleContactBirthdayWidget()
        BirthdayLiveActivity()
    }
}

import SwiftUI

struct SpecialDatesListView: View {
    @ObservedObject var contactManager: ContactManager
    @Binding var selectedContactForEdit: Contact?

    var body: some View {
        List {
            ForEach(contactManager.specialDatesContacts, id: \.specialDate.id) { contact, specialDate in
                SpecialDateRow(contact: contact, specialDate: specialDate) {
                    selectedContactForEdit = contact
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if contactManager.specialDatesContacts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No special dates yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Edit a contact to add an anniversary or other recurring date.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
}

struct SpecialDateRow: View {
    let contact: Contact
    let specialDate: SpecialDate
    let onTap: () -> Void

    @State private var isAnimating = false

    private var isToday: Bool { specialDate.daysUntilNext == 0 }
    private var years: Int { specialDate.yearsElapsed }
    // years elapsed when today, years+1 when upcoming
    private var anniversaryNumber: Int { isToday ? years : years + 1 }

    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)th"
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
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
                if contact.isDeceased {
                    Text("🕊").font(.system(size: 14)).offset(x: 4, y: 4)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                HStack(spacing: 6) {
                    Text(formattedDate(specialDate.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(specialDate.displayLabel)
                        .font(.caption)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.purple.opacity(0.12)))
                }
            }

            Spacer()

            // Countdown / anniversary celebration
            VStack(alignment: .trailing, spacing: 2) {
                if isToday {
                    Text("🎉")
                        .font(.title2)
                        .scaleEffect(isAnimating ? 1.15 : 0.9)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0),
                            value: isAnimating
                        )
                    Text("\(ordinal(anniversaryNumber)) anniversary!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                } else {
                    Text(specialDate.monthsUntilNext)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("til \(ordinal(anniversaryNumber)) anniversary")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .padding(.vertical, 4)
        .onAppear {
            if isToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { isAnimating = true }
            }
        }
        .onDisappear { isAnimating = false }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

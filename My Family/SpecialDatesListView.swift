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

    private var isToday: Bool { specialDate.daysUntilNext == 0 }

    var body: some View {
        Button(action: onTap) {
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
                            .grayscale(contact.isDeceased ? 0.8 : 0)
                            .opacity(contact.isDeceased ? 0.75 : 1)
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
                    HStack(spacing: 4) {
                        Text(specialDate.displayLabel)
                            .font(.caption)
                            .foregroundColor(.purple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.purple.opacity(0.12)))
                        Text("·")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedDate(specialDate.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Countdown
                VStack(alignment: .trailing, spacing: 2) {
                    if isToday {
                        Text("🎉")
                            .font(.title2)
                        Text("TODAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    } else {
                        Text(specialDate.monthsUntilNext)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Text("til \(specialDate.displayLabel.lowercased())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}

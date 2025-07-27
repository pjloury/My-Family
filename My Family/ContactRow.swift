import SwiftUI

struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
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
                    Text(contact.birthdayString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(contact.zodiacSign)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(contact.chineseZodiacAnimal)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Time Info - Right side
            VStack(alignment: .trailing, spacing: 2) {
                Text(contact.monthsUntilBirthday)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("til next b-day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContactRow(contact: Contact(
        name: "John Doe", firstName: "John",
        nickname: nil,
        birthday: Date().addingTimeInterval(-30*365*24*60*60), // 30 years ago
        photoData: nil
    ))
    .padding()
} 

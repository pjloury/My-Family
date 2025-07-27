import SwiftUI
import Contacts
import UIKit

struct BirthdayInputView: View {
    let contact: CNContact
    let onBirthdaySelected: (Date) -> Void
    let onCancel: () -> Void
    
    @State private var selectedDate: Date
    @State private var showingDatePicker = false
    
    init(contact: CNContact, onBirthdaySelected: @escaping (Date) -> Void, onCancel: @escaping () -> Void) {
        self.contact = contact
        self.onBirthdaySelected = onBirthdaySelected
        self.onCancel = onCancel
        
        // Initialize with known birthday information
        if let birthday = contact.birthday,
           let month = birthday.month,
           let day = birthday.day {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            
            // Use the known month and day, with current year as default
            // This provides a reasonable starting point that the user can adjust
            let components = DateComponents(year: currentYear, month: month, day: day)
            self._selectedDate = State(initialValue: calendar.date(from: components) ?? Date())
        } else {
            // Fallback to today's date if no birthday info is available
            self._selectedDate = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Contact Info
                VStack(spacing: 12) {
                    if let imageData = contact.imageData, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(contact.givenName) \(contact.familyName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let birthday = contact.birthday {
                        Text("Current: \(birthday.month ?? 0)/\(birthday.day ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Complete Birthday Required")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Please select the complete birthdate (month, day, and year) to add this person to your family list.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Date Display
                VStack(spacing: 8) {
                    Text("Selected Birthday:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(selectedDate, style: .date)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Date Picker Button
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Select Birthday")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("Add to Family") {
                        onBirthdaySelected(selectedDate)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Complete Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $selectedDate)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Complete Birthday",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
} 
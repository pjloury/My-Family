import SwiftUI

struct NotificationPermissionView: View {
    @Binding var isPresented: Bool
    let onPermissionRequested: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .scaleEffect(1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true),
                        value: true
                    )
                
                Text("Birthday Reminders")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Feature explanation
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Weekly Birthday Digest",
                    description: "Every week, see all upcoming birthdays listed with day and date — e.g. \"next Thursday, Jan 7: Gary Wong\""
                )
                
                FeatureRow(
                    icon: "gift.fill",
                    title: "Birthday Day Alert",
                    description: "Receive a special notification on the actual birthday at 9 AM"
                )
                
                FeatureRow(
                    icon: "clock.fill",
                    title: "Perfect Timing",
                    description: "Be there for the most important people in your life"
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    isPresented = false
                    onPermissionRequested()
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Enable Notifications")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Maybe Later")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 32)
        .background(Color(.systemBackground))
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NotificationPermissionView(
        isPresented: .constant(true),
        onPermissionRequested: {}
    )
} 
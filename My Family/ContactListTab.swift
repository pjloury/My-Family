import SwiftUI

struct ContactListTab: View {
    let title: String
    let isSelected: Bool
    let primaryColor: Color
    let secondaryColor: Color
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Blue line indicator at the top
                Rectangle()
                    .fill(isSelected ? .blue : Color.clear)
                    .frame(height: 4)
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .frame(width: 100, height: 60)
            .background(isPressed ? Color.primary.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50, perform: onLongPress, onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        })
    }
} 
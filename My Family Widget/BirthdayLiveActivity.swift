import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Attributes (must match BirthdayActivityManager.swift in main app)

struct BirthdayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contactName: String
        var firstName: String
        var birthdayAge: Int
    }

    var contactId: String
}

// MARK: - Live Activity Views

@available(iOS 16.2, *)
struct BirthdayLiveActivityView: View {
    let context: ActivityViewContext<BirthdayActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Text("🎂")
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text("Happy Birthday!")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Today is \(context.state.firstName)'s \(context.state.birthdayAge)\(ordinal(context.state.birthdayAge)) birthday")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }

    private func ordinal(_ n: Int) -> String {
        let mod100 = n % 100
        if mod100 >= 11 && mod100 <= 13 { return "th" }
        switch n % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}

// MARK: - Widget Configuration

@available(iOS 16.2, *)
struct BirthdayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BirthdayActivityAttributes.self) { context in
            BirthdayLiveActivityView(context: context)
                .activityBackgroundTint(Color.pink.opacity(0.12))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🎂")
                        .font(.system(size: 28))
                        .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text("Happy Birthday!")
                            .font(.headline)
                        Text(context.state.firstName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.birthdayAge)")
                        .font(.title2.bold())
                        .foregroundColor(.pink)
                        .padding(.trailing, 4)
                }
            } compactLeading: {
                Text("🎂")
            } compactTrailing: {
                Text(context.state.firstName)
                    .font(.caption.bold())
                    .lineLimit(1)
            } minimal: {
                Text("🎂")
            }
        }
    }
}

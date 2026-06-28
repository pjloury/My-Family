import SwiftUI

struct NotificationTimingSettingsView: View {
    @Binding var isPresented: Bool
    @State private var settings = NotificationTimingSettings.load()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Remind me before each birthday")) {
                    TimingToggleRow(
                        label: "1 month before",
                        icon: "calendar",
                        isOn: $settings.oneMonthBefore
                    )
                    TimingToggleRow(
                        label: "1 week before",
                        icon: "calendar.badge.clock",
                        isOn: $settings.oneWeekBefore
                    )
                    TimingToggleRow(
                        label: "3 days before",
                        icon: "calendar.badge.exclamationmark",
                        isOn: $settings.threeDaysBefore
                    )
                    TimingToggleRow(
                        label: "1 day before",
                        icon: "alarm",
                        isOn: $settings.oneDayBefore
                    )
                    TimingToggleRow(
                        label: "Day of",
                        icon: "gift.fill",
                        isOn: $settings.dayOf
                    )
                }

                Section(footer: Text("Notifications fire at 9 AM on the selected days.")) {
                    EmptyView()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notification Timing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        settings.save()
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct TimingToggleRow: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(label, systemImage: icon)
        }
        .tint(.blue)
    }
}

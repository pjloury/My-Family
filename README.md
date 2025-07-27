# My Family - Birthday Tracker

A SwiftUI iOS app for tracking family members' birthdays and ages. The app allows you to select contacts from your device's contact list and displays them in a beautiful list view with birthday information.

## Features

### 📱 Single Page Design
- Clean, focused interface with a title bar showing "My Family"
- Add button in the top-right corner for adding new family members
- Empty state with helpful instructions when no family members are added

### 👥 Contact Management
- **Add Family Members**: Tap the + button to access your device's contacts
- **Smart Search**: Search through contacts by name or nickname with real-time filtering
- **Strict Predefined Label Filtering**: Suggested contacts must have related names using only predefined iOS label types (Father, Mother, Parent, Brother, Sister, Child, Son, Daughter, Spouse, Partner) - excludes custom or user-generated labels
- **Smart Sorting**: Contacts are automatically sorted with likely family members at the top
- **Complete Birthday Required**: Only contacts with full birthday information (month/day/year) can be added
- **Birthday Input**: For contacts with incomplete birthdays, the app prompts you to select the birth year
- **Contact Updates**: Automatically saves the complete birthday back to your contacts
- **Birthday Display**: Shows birthdays in "Jan 15, 1990" format in the contact picker
- **Already Added Indicator**: Contacts already in your family list show "(Added)" and are disabled
- **Full Row Tap Target**: Tap anywhere on a contact row to select it (not just the plus button)
- **Enhanced Information Hierarchy**: 
  - **Left side**: Contact name and age combined as "Dad • 45" (primary) and birthday in "February 2nd, 1963" format (secondary)
  - **Right side**: Time until next birthday in "4 months" format (primary) and "til next b-day" label (secondary)
  - **Smart Time Display**: Shows days when less than 1 month away (e.g., "10 days")
- **Photo Support**: Displays contact photos in circular format, with fallback to system icon
- **Swipe to Delete**: Remove family members by swiping left on their entry
- **Performance Optimized**: Cached scoring, debounced search, and efficient filtering for smooth performance

### 🎂 Birthday Information Display
Each family member shows:
- **Name**: Nickname (if available) or full name from contacts
- **Photo**: Circular profile picture or system icon
- **Age**: Calculated age in years
- **Birthday**: Formatted birthday date
- **Days Until Next Birthday**: Countdown to next birthday (highlighted in red if ≤30 days)

### 🔄 Sorting Options
Sort your family list by:
- **Name**: Alphabetical order
- **Age**: Oldest to youngest
- **Birthday**: Chronological order
- **Days Until Birthday**: Soonest birthdays first

### 💾 Data Persistence
- Family members are automatically saved to device storage
- App remembers your family list between launches
- No cloud sync required - all data stays on your device

### 🧠 Smart Family Detection
The app uses an intelligent algorithm to prioritize likely family members:
- **Family Keywords**: Detects names containing "mom", "dad", "grandma", etc.
- **Contact Details**: Prioritizes contacts with photos, multiple phone numbers, and email addresses
- **Nicknames**: Considers contact nicknames and notes for family identification
- **Organization Filtering**: Deprioritizes contacts with job titles and company information
- **High-Confidence Suggestions**: Shows up to 6 high-confidence family contacts in a dedicated "Suggested" section

## Privacy & Permissions

The app requires access to your contacts to:
- Display available contacts with birthdays
- Import contact photos and information
- Add family members to your list

**Note**: The app only accesses contacts when you tap the + button to add family members. Your contact data is not uploaded or shared.

## Technical Details

- **Framework**: SwiftUI
- **iOS Target**: iOS 18.0+
- **Language**: Swift
- **Data Storage**: UserDefaults with JSON encoding
- **Contact Access**: CNContact framework

## Getting Started

1. **Launch the app** - You'll see an empty state with instructions
2. **Add family members** - Tap the + button in the top-right
3. **Grant permissions** - Allow access to contacts when prompted
4. **Search and select** - Use the search bar to find contacts, or browse the smart-sorted list
5. **Complete birthdays** - For contacts with incomplete birthdays, select the birth year when prompted
6. **View your family** - See all family members with their birthday information
7. **Sort and manage** - Use the sort picker and swipe to delete as needed

## Building the App

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run the project
4. The app will request contact permissions on first use

## File Structure

```
My Family/
├── My_FamilyApp.swift          # App entry point
├── ContentView.swift           # Main view with list and controls
├── Contact.swift              # Contact model and sort options
├── ContactManager.swift       # Data management and persistence
├── ContactRow.swift           # Individual contact row view
├── ContactPicker.swift        # Contact selection interface
└── Assets.xcassets/          # App icons and assets
```

The app is designed to be simple, focused, and user-friendly while providing all the essential features for tracking family birthdays. 
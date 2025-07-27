import SwiftUI

struct ContactListTabView: View {
    @ObservedObject var contactManager: ContactManager
    @State private var showingNewListAlert = false
    @State private var newListTitle = ""
    @State private var showingDeleteAlert = false
    @State private var listToDelete: Int?
    
    // Color scheme using adjacent colors from Flat UI palette
    private var tabColors: [Color] {
        if ContactManager.useFlatUIColors {
            return [
                Color(red: 0.925, green: 0.235, blue: 0.235), // Flat Red
                Color(red: 0.925, green: 0.431, blue: 0.235), // Flat Orange
                Color(red: 0.925, green: 0.627, blue: 0.235), // Flat Yellow
                Color(red: 0.235, green: 0.925, blue: 0.235), // Flat Green
                Color(red: 0.235, green: 0.627, blue: 0.925), // Flat Blue
                Color(red: 0.627, green: 0.235, blue: 0.925), // Flat Purple
            ]
        } else {
            // Stock iOS colors - use blue for all tabs
            return Array(repeating: Color.blue, count: 6)
        }
    }
    
    private var tabBarContent: some View {
        HStack(spacing: 0) {
            // List tabs
            ForEach(Array(contactManager.contactLists.enumerated()), id: \.element.id) { index, list in
                let truncatedTitle = String(list.title.prefix(12))
                let isSelected = index == contactManager.selectedListIndex
                let primaryColor = tabColors[index % tabColors.count]
                let secondaryColor = tabColors[index % tabColors.count].opacity(0.7)
                
                ContactListTab(
                    title: truncatedTitle,
                    isSelected: isSelected,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    onTap: {
                        print("Tab tapped: \(list.title)")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            contactManager.selectedListIndex = index
                        }
                    },
                    onLongPress: {
                        print("Long press detected for list: \(list.title)")
                        listToDelete = index
                        showingDeleteAlert = true
                    }
                )
                .frame(width: 100, height: 60)
            }
            
            // Add new list button
            Button(action: {
                showingNewListAlert = true
            }) {
                Text("+")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 60)
                    .background(Color.red)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 100)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(contactManager.contactLists.enumerated()), id: \.element.id) { index, list in
                        let truncatedTitle = String(list.title.prefix(12))
                        let isSelected = contactManager.selectedListIndex == index
                        let primaryColor = ContactManager.useFlatUIColors ? tabColors[index % tabColors.count] : .blue
                        let secondaryColor = ContactManager.useFlatUIColors ? primaryColor.opacity(0.3) : .blue.opacity(0.3)
                        
                        ContactListTab(
                            title: truncatedTitle,
                            isSelected: isSelected,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    contactManager.selectedListIndex = index
                                }
                            },
                            onLongPress: {
                                listToDelete = index
                                showingDeleteAlert = true
                            }
                        )
                    }
                    
                    // Add new list button
                    Button(action: {
                        showingNewListAlert = true
                    }) {
                        Text("+")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ContactManager.useFlatUIColors ? .white : .blue)
                            .frame(width: 100, height: 60)
                            .background(ContactManager.useFlatUIColors ? Color(red: 0.925, green: 0.235, blue: 0.235) : Color.clear)
                    }
                }
            }
            .background(ContactManager.useFlatUIColors ? Color(red: 0.925, green: 0.235, blue: 0.235).opacity(0.1) : Color.clear)
        }
        .alert("New List", isPresented: $showingNewListAlert) {
            TextField("List name", text: $newListTitle)
            Button("Cancel", role: .cancel) {
                newListTitle = ""
            }
            Button("Create") {
                if !newListTitle.isEmpty {
                    contactManager.addNewList(title: newListTitle)
                    newListTitle = ""
                }
            }
        } message: {
            Text("Enter a name for your new list")
        }
        .alert("Delete List", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let index = listToDelete {
                    print("Deleting list at index: \(index)")
                    contactManager.deleteList(at: index)
                }
            }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
    }
}

#Preview {
    ContactListTabView(contactManager: ContactManager())
} 
//
//  ContentView.swift
//  My Family
//
//  Created by PJ Loury on 7/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var contactManager = ContactManager()
    @State private var showingContactPicker = false
    @State private var selectedContactForEdit: Contact?
    @State private var isEditingTitle = false
    @State private var editingTitle = ""
    @FocusState private var isTitleFieldFocused: Bool
    @State private var showingDeleteListAlert = false
    
    private var editingTitleBinding: Binding<String> {
        Binding(
            get: { editingTitle },
            set: { editingTitle = $0 }
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sort Picker
                HStack {
                    Text("Sort by:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Sort", selection: Binding(
                        get: { contactManager.currentList?.selectedSortOption ?? .name },
                        set: { contactManager.updateSortOption($0) }
                    )) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: contactManager.currentList?.selectedSortOption) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            contactManager.sortContacts()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            contactManager.toggleSortDirection()
                        }
                    }) {
                        Text(contactManager.currentList?.sortDirection.arrow ?? "⬆️")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                ContactListView(contactManager: contactManager, selectedContactForEdit: $selectedContactForEdit)
                
                // Tab bar at bottom
                ContactListTabView(contactManager: contactManager)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        editingTitle = (contactManager.currentList?.title ?? "My Family")
                        isEditingTitle = true
                    }) {
                        ZStack {
                            Text(contactManager.currentList?.title ?? "My Family")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .id(contactManager.currentList?.title ?? "My Family")
                                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                        }
                        .animation(.easeInOut(duration: 0.6), value: contactManager.currentList?.title)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingContactPicker = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(contactManager: contactManager)
            }
            .sheet(item: $selectedContactForEdit) { contact in
                ContactEditView(contact: contact, contactManager: contactManager)
            }
            .overlay(
                Group {
                    if isEditingTitle {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isEditingTitle = false
                            }
                        
                        VStack(spacing: 20) {
                            Text("Edit Title")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Enter title", text: editingTitleBinding)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .padding(.horizontal, 20)
                                .focused($isTitleFieldFocused)
                                .onChange(of: editingTitle) { newValue in
                                    // Limit to 12 characters
                                    if newValue.count > 12 {
                                        editingTitle = String(newValue.prefix(12))
                                    }
                                }
                                .onAppear {
                                    // Focus the field when modal appears
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isTitleFieldFocused = true
                                    }
                                }
                            
                            HStack(spacing: 15) {
                                Button("Cancel") {
                                    isEditingTitle = false
                                }
                                .foregroundColor(.secondary)
                                
                                Button("Save") {
                                    if !editingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        contactManager.updateCurrentListTitle(editingTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                                    }
                                    isEditingTitle = false
                                }
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            }
                            
                            Divider()
                            
                            Button("Delete List") {
                                showingDeleteListAlert = true
                            }
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isEditingTitle)
            )
        }
        .onAppear {
            contactManager.sortContacts()
        }
        .alert("Delete List", isPresented: $showingDeleteListAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                contactManager.deleteCurrentList()
                isEditingTitle = false
            }
        } message: {
            Text("Are you sure you want to delete this list? This action cannot be undone.")
        }
    }
}

struct ContactListView: View {
    @ObservedObject var contactManager: ContactManager
    @Binding var selectedContactForEdit: Contact?
    
    var body: some View {
        if let currentList = contactManager.currentList {
            if currentList.contacts.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "person.3")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Build your Family")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Tap the + button to add contacts from your device")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(currentList.contacts) { contact in
                        ContactRow(contact: contact) {
                            selectedContactForEdit = contact
                        }
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                    }
                    .onDelete(perform: contactManager.deleteContact)
                }
                .listStyle(PlainListStyle())
                .animation(.easeInOut(duration: 0.5), value: currentList.contacts.map { $0.id })
            }
        }
    }
}

#Preview {
    ContentView()
}

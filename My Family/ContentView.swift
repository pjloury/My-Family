//
//  ContentView.swift
//  My Family
//
//  Created by PJ Loury on 7/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var contactManager = ContactManager()
    @State private var showingContactPicker = false
    @State private var title = UserDefaults.standard.string(forKey: "CustomTitle") ?? "My Family"
    @State private var isEditingTitle = false
    @State private var editingTitle = ""
    @FocusState private var isTitleFieldFocused: Bool
    
    // Custom binding that selects all text when focused
    private var editingTitleBinding: Binding<String> {
        Binding(
            get: { editingTitle },
            set: { newValue in
                editingTitle = newValue
                // If this is the first time the field is focused, select all text
                if isTitleFieldFocused && editingTitle == title {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // This will trigger text selection by briefly changing the value
                        editingTitle = newValue + " "
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            editingTitle = String(newValue)
                        }
                    }
                }
            }
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
                    
                    Picker("Sort", selection: $contactManager.selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: contactManager.selectedSortOption) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            contactManager.sortContacts()
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                // Contact List
                if contactManager.contacts.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "person.3")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("No Family Members")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Tap the + button to add family members from your contacts")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(contactManager.contacts) { contact in
                            ContactRow(contact: contact)
                                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
                        }
                        .onDelete(perform: contactManager.deleteContact)
                    }
                    .listStyle(PlainListStyle())
                    .animation(.easeInOut(duration: 0.5), value: contactManager.contacts.map { $0.id })
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        editingTitle = title
                        isEditingTitle = true
                    }) {
                        Text(title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
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
                                        title = editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                                        UserDefaults.standard.set(title, forKey: "CustomTitle")
                                    }
                                    isEditingTitle = false
                                }
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            }
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
    }
}

#Preview {
    ContentView()
}

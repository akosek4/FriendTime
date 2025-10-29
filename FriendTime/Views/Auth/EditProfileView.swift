//
//  EditProfileView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/28/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var displayName = ""
    @State private var username = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Display Name", text: $displayName)
                    TextField("Username", text: $username)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .disabled(isSaving)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let user = viewModel.currentUser {
                    displayName = user.displayName ?? "Unknown display name"
                    username = user.username
                }
            }
        }
    }
    
    private func saveChanges() async {
        isSaving = true
        defer { isSaving = false }
        
        await viewModel.updateUserProfile(
            displayName: displayName,
            username: username,
        )
        
        dismiss()
    }
}

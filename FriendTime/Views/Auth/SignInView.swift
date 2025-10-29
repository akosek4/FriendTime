//
//  SignInView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button {
                Task { await handleSignIn() }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(isLoading)
        }
        .padding()
    }
    
    func handleSignIn() async {
        isLoading = true
        defer { isLoading = false}
        
        do {
            let uid = try await AuthService.shared.signIn(email: email, password: password)
            try await viewModel.fetchUserProfile(uid: uid)
            print("User signed in successfully")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

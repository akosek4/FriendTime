//
//  SignUpView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var showLocationInfo = false
    @State private var isLoading = false
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Display Name", text: $displayName)
                .textFieldStyle(.roundedBorder)

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                showLocationInfo = true
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(!isFormValid || isLoading)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showLocationInfo) {
            LocationInfoModal {
                showLocationInfo = false
                Task { await viewModel.signUp(email: email, password: password, displayName: displayName, username: username) }
            }
        }
    }
}

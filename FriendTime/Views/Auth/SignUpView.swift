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
    @State private var errorMessage: String?
    
    @StateObject private var viewModel = AuthViewModel()
    
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

                if let errorMessage = errorMessage {
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
                .disabled(isLoading)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showLocationInfo) {
                LocationInfoModal {
                    showLocationInfo = false
                    Task { await handleSignUp() }
                }
            }
        }
    
    func handleSignUp() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let uid = try await AuthService.shared.signUp(email: email, password: password)

            let timezone = await fetchTimezoneStub()

            try await FirestoreService.shared.createUserProfile(uid: uid, displayName: displayName, username: username, email: email, timezone: timezone)

            print("User created with UID: \(uid)")

        } catch {
            if let nsError = error as NSError?, nsError.domain == "FirestoreService" {
                errorMessage = nsError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    //TODO
    func fetchTimezoneStub() async -> String {
        return TimeZone.current.identifier
    }
}

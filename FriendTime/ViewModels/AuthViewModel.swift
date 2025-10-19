//
//  AuthViewModel.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI
import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var userID: String? = nil
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil
    
    init() {
        userID = AuthService.shared.currentUID
        isAuthenticated = userID != nil
    }
    
    func signUp(email: String, password: String) async {
        do {
            let uid = try await AuthService.shared.signUp(email: email, password: password)
            userID = uid
            isAuthenticated = true
            errorMessage = nil
            print("Signed up successfully with UID: \(uid)")
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            print("Sign up failed:", error.localizedDescription)
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            let uid = try await AuthService.shared.signIn(email: email, password: password)
            userID = uid
            isAuthenticated = true
            errorMessage = nil
            print("Signed in successfully with UID: \(uid)")
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            print("Sign in failed:", error.localizedDescription)
        }
    }
    
    func signOut() async {
        do {
            try  AuthService.shared.signOut()
            userID = nil
            isAuthenticated = false
            errorMessage = nil
            print("Signed out successfully.")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign out failed:", error.localizedDescription)
        }
    }
}

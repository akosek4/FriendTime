//
//  AuthViewModel.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI
import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var userID: String? = nil
    @Published var currentUser: UserModel? = nil
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil
    
    init() {
        userID = AuthService.shared.currentUID
        isAuthenticated = userID != nil
        
        if let uid = userID {
            Task { await loadUserProfile(uid: uid) }
        }
    }
    
    func signUp(email: String, password: String) async {
        do {
            let uid = try await AuthService.shared.signUp(email: email, password: password)
            userID = uid
            isAuthenticated = true
            errorMessage = nil
            print("Signed up successfully with UID: \(uid)")
            
            await loadUserProfile(uid: uid)
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
            
            await loadUserProfile(uid: uid)
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
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
            print("Signed out successfully.")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign out failed:", error.localizedDescription)
        }
    }
    
    func loadUserProfile(uid: String) async {
        do {
            let user = try await FirestoreService.shared.fetchUserProfile(uid: uid)
            currentUser = user
            print("Loaded user profile for \(user.displayName)")
        } catch {
            print("Failed to fetch user profile:", error.localizedDescription)
        }
    }
    
    func fetchUserProfile(uid: String) async throws -> UserModel {
        return try await FirestoreService.shared.fetchUserProfile(uid: uid)
    }
}

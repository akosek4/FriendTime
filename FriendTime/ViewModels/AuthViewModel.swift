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
import CoreLocation

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
    
    func signUp(email: String, password: String, displayName: String, username: String) async {
        do {
            let uid = try await AuthService.shared.signUp(email: email, password: password)
            let (coordinate, timezoneID) = await LocationService.shared.requestLocationOnce()
            let lastLocation: [String: Double]? = coordinate.map {
                ["lat": $0.latitude, "lon": $0.longitude]
            }
            
            do {
                try await FirestoreService.shared.createUserProfile(uid: uid, displayName: displayName, username: username, email: email, timezone: timezoneID, lastLocation: lastLocation)
            } catch {
                print("Firestore creation failed, rolling back user: \(error.localizedDescription)")
                try? await AuthService.shared.deleteCurrentUser()
                throw error
            }

            userID = uid
            isAuthenticated = true
            errorMessage = nil
            
            print("Signed up successfully with UID: \(uid)")
            
            await loadUserProfile(uid: uid)
        } catch {
            if let nsError = error as NSError? {
                    switch nsError.domain {
                    case "FirestoreService":
                        if nsError.code == 0 {
                            errorMessage = "That email is already in use."
                        } else if nsError.code == 1 {
                            errorMessage = "That username is already taken. Try another one."
                        } else {
                            errorMessage = "Something went wrong while creating your account."
                        }

                    case NSURLErrorDomain:
                        errorMessage = "Network error. Check your connection and try again."
                        
                    case AuthErrorDomain:
                        if let err = error as NSError? {
                            if let errorCode = AuthErrorCode(rawValue: err.code) {
                                switch errorCode {
                                case .emailAlreadyInUse:
                                    errorMessage = "That email is already in use."
                                case .networkError:
                                    errorMessage = "Network error — check your internet connection."
                                case .weakPassword:
                                    errorMessage = "Password must be at least 6 characters long."
                                case .invalidEmail:
                                    errorMessage = "Please enter a valid email."
                                default:
                                    errorMessage = err.localizedDescription
                                }
                            }
                        }

                    default:
                        if nsError.localizedDescription.contains("denied") ||
                           nsError.localizedDescription.contains("Location") {
                            errorMessage = "We couldn’t access your location. Please enable permissions in Settings."
                        } else {
                            errorMessage = "Sign up failed: \(nsError.localizedDescription)"
                        }
                    }
                } else {
                errorMessage = error.localizedDescription
            }
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
            print("Loaded user profile for \(user.displayName ?? "unknown")")
        } catch {
            print("Failed to fetch user profile:", error.localizedDescription)
        }
    }
    
    func fetchUserProfile(uid: String) async throws -> UserModel {
        return try await FirestoreService.shared.fetchUserProfile(uid: uid)
    }
    
    func updateUserProfile(displayName: String, username:String) async {
        guard let uid = userID else { return }
        let updateData: [String: Any] = [
            "displayName": displayName,
            "username": username
        ]
        
        do {
            try await FirestoreService.shared.updateUserProfile(uid: uid, data: updateData)
            await loadUserProfile(uid: uid)
            print("User profile updated")
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to update profile:", error.localizedDescription)
        }
    }
}

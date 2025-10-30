//
//  AuthService.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signUp(email:String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    func signIn(email:String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {return}
        try await user.delete()
    }
    
    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }
}

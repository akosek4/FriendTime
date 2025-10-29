//
//  FirestoreService.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    
    private let db = Firestore.firestore()
    
    func createUserProfile(uid: String, displayName: String, username: String, email: String, timezone: String, lastLocation: [String: Double]? = nil)  async throws {
        let lowerUsername = username.lowercased()
        let usernamesRef = db.collection("usernames").document(lowerUsername)
        let usersRef = db.collection("users").document(uid)
        
        try await db.runTransaction { transaction, errorPointer in
            var usernameDoc: DocumentSnapshot?
            do {
                usernameDoc = try transaction.getDocument(usernamesRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let usernameDoc = usernameDoc else {
                errorPointer?.pointee = NSError(
                    domain: "FirestoreService",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch username document."]
                )
                return nil
            }
            
            if usernameDoc.exists {
                errorPointer?.pointee = NSError(
                    domain: "FirestoreService",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Username already taken."]
                )
                return nil
            }
            
            transaction.setData([
                "uid": uid,
                "createdAt": FieldValue.serverTimestamp(),
            ], forDocument: usernamesRef)
            
            var userData: [String: Any] = [
                "uid": uid,
                "username": lowerUsername,
                "displayName": displayName,
                "email": email,
                "timezone": timezone,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            if let lastLocation = lastLocation {
                userData["lastLocation"] = lastLocation
            }
            
            transaction.setData(userData, forDocument: usersRef)
            return nil
        }
    }
    
    func updateUser(uid: String, timezone: TimeZone, lastLocation: [String: Double]?) async throws {
        var data: [String: Any] = [
            "timezone": timezone.identifier,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        if let lastLocation = lastLocation {
            data["lastLocation"] = lastLocation
        }
        
        try await db.collection("users").document(uid).setData(data, merge: true)
    }
    
    func fetchUserProfile(uid: String) async throws -> UserModel {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data() else {
            throw NSError(domain: "FirestoreService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User document not found."])
        }
        var user = UserModel(from: data)
        user.id = doc.documentID
        return user
    }
}

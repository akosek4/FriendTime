//
//  UserModel.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import Foundation

struct UserModel: Identifiable, Codable {
    var id: String?
    var email: String
    var username: String
    var lastLocation: String?
    var timezone: String?
    var displayName: String?
    
    init(id: String? = nil, email: String, username: String, lastLocation: String? = nil, timezone: String? = nil, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.username = username
        self.lastLocation = lastLocation
        self.timezone = timezone
    }
    
    init(from data: [String: Any]) {
        self.id = data["uid"] as? String
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.lastLocation = data["lastLocation"] as? String
        self.timezone = data["timezone"] as? String
        self.displayName = data["displayName"] as? String
    }
}

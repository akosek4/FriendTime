//
//  HomeViewModel.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/28/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var formattedLocalTime = ""
    
    private var cancellables = Set<AnyCancellable>()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    func loadUser() async {
        isLoading = true
        defer { isLoading = false}
        
        do {
            guard let uid = AuthService.shared.currentUID else {
                errorMessage = "User not authenticated."
                return
            }
            
            let user = try await FirestoreService.shared.fetchUserProfile(uid: uid)
            self.user = user
            updateTime()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateTime() {
        guard let tz = user?.timezone, let timezone = TimeZone(identifier:  tz) else {
            formattedLocalTime = "Unknown"
            return
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.timeStyle = .short
        formattedLocalTime = formatter.string(from: Date())
    }
}

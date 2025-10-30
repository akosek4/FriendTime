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
    @Published var formattedLocalTime = ""
    private var cancellables = Set<AnyCancellable>()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    init() {
        timer
            .sink { [weak self] _ in
                self?.updateTime()
            }
            .store(in: &cancellables)
    }
    
    private var timezone: TimeZone?
    
    func configure(with timezoneIdentifier: String?) {
        if let id = timezoneIdentifier, let tz = TimeZone(identifier: id) {
            timezone = tz
            updateTime()
        } else {
            formattedLocalTime = "Unknown"
        }
    }
    
    func updateTime() {
        guard let tz = timezone else {
            formattedLocalTime = "Unknown"
            return
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.timeStyle = .short
        formattedLocalTime = formatter.string(from: Date())
    }
}

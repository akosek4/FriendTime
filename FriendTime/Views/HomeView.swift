//
//  HomeView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = authViewModel.currentUser {
                VStack(spacing: 8) {
                    Text(user.displayName ?? "No name")
                        .font(.title)
                        .bold()
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Local time: \(homeViewModel.formattedLocalTime)")
                        .font(.headline)
                        .monospacedDigit()
                }
                .padding()
                .onAppear {
                    homeViewModel.configure(with: user.timezone)
                }
            } else {
                ProgressView("Loading profile…")
            }

            Spacer()

            HStack {
                Button("Edit Profile") {
                    showEditProfile = true
                }
                .buttonStyle(.bordered)

                Button("Sign Out") {
                    Task { await authViewModel.signOut() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authViewModel)
        }
    }
}

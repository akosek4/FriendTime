//
//  HomeView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = viewModel.user {
                VStack(spacing: 8) {
                    Text(user.displayName!)
                        .font(.title)
                        .bold()
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Local time: \(viewModel.formattedLocalTime)")
                        .font(.headline)
                        .monospacedDigit()
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView("Loading profile…")
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Spacer()

            HStack {
                Button("Edit Profile") {
                    // Placeholder for later phase
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
        .task {
            await viewModel.loadUser()
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.updateTime()
        }
    }
}

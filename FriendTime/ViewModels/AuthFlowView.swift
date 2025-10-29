//
//  AuthFlowView.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/28/25.
//

import SwiftUI

struct AuthFlowView: View {
    @State private var showingSignUp = false
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                if showingSignUp {
                    SignUpView()
                } else {
                    SignInView()
                }

                Button(showingSignUp ? "Already have an account? Sign In" : "Don’t have an account? Sign Up") {
                    withAnimation { showingSignUp.toggle() }
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
    }
}

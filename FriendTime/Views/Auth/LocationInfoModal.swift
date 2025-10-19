//
//  LocationInfoModal.swift
//  FriendTime
//
//  Created by Alyson Kosek on 10/18/25.
//

import SwiftUI

struct LocationInfoModal: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Why We Need Your Location")
                .font(.title2)
                .bold()

            Text("FriendTime uses your location to determine your current timezone, so your friends always see the correct local time for you. You can change permissions anytime in Settings.")
                .multilineTextAlignment(.leading)

            Spacer()

            Button("Continue") {
                onContinue()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

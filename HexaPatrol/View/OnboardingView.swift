//
//  OnboardingView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 10/02/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Image("PatrolChecking")
                        .resizable()
                        .padding()
                        .scaledToFit()
                }
                .padding(.top, 10)
                
                VStack(spacing: 16) {
                    Text("Equipment Patrol Management")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    
                    Text("Optimizing task management for\nimproved business performance")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Sign in")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Button("Register") {}
                            .foregroundColor(.purple)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    OnboardingView()
}

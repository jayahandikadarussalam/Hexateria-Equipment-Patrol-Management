//
//  LoginView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var showURLSettings = false
    @EnvironmentObject var viewModel: APIService
    @Environment(\.colorScheme) var colorScheme
    
    private var buttonColor: Color {
        (colorScheme == .dark ? Color(.white) : Color.black)
    }
    
    var body: some View {
            NavigationStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Equipment Patrol Management")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Log in now to continue patrol")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    
                    HStack {
                        Image("PatrolChecking")
                            .resizable()
                            .padding()
                            .scaledToFit()
                    }
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            InputView(text: $viewModel.email,
                                      title: "Email Address",
                                      placeholder: "name@example.com")
                            .autocapitalization(.none)
                            ValidationMessageView(condition: !viewModel.email.isEmpty && (!viewModel.email.contains("@") || !viewModel.email.contains(".")),
                                                  message: "Please enter a valid email.")
                        }
                        
                        VStack(alignment: .leading) {
                            InputView(text: $viewModel.password,
                                      title: "Password",
                                      placeholder: "enter your password",
                                      isSecureField: true)
                            ValidationMessageView(condition: !viewModel.password.isEmpty && viewModel.password.count < 6,
                                                  message: "Password is less than 6 characters.")
                        }
                        .padding(.bottom, 10)
                        
                        HStack(spacing: 10) {
                            // Gear Button
                            Button {
                                showURLSettings = true
                            } label: {
                                Image(systemName: "gear")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(buttonColor)
                                    .frame(width: 48, height: 48)
                                    .background(Color(.systemMint))
                                    .cornerRadius(8)
                            }
                            
                            // Sign In Button
                            Button {
                                Task {
                                    await viewModel.login(email: viewModel.email, password: viewModel.password)
                                }
                            } label: {
                                HStack {
                                    Text("SIGN IN")
                                        .fontWeight(.semibold)
                                        .foregroundColor(buttonColor)
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(buttonColor)
                                }
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color(.systemMint))
                                .cornerRadius(8)
                            }
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1.0 : 0.5)
                        }
                        
//                        Button {
//                            Task {
//                                await viewModel.login(email: viewModel.email, password: viewModel.password)
//                            }
//                        } label: {
//                            HStack {
//                                Text("SIGN IN")
//                                    .fontWeight(.semibold)
//                                Image(systemName: "arrow.right")
//                            }
//                            .foregroundColor(Color.white)
//                            .frame(maxWidth: .infinity, minHeight: 48)
//                            .background(Color(.systemMint))
//                            .cornerRadius(8)
//                        }
//                        .disabled(!formIsValid)
//                        .opacity(formIsValid ? 1.0 : 0.5)
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding()
            .sheet(isPresented: $showURLSettings) {
                URLSettingsView()
            }
        }
    }

let screen = UIScreen.main.bounds

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !viewModel.email.isEmpty
        && viewModel.email.contains("@")
        && !viewModel.password.isEmpty
        && viewModel.password.count > 5
    }
}

#Preview {
    LoginView()
        .environmentObject(APIService())
}

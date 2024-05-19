//
//  LoginView.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Image
                Image("image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 30)

                // Form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                        .textInputAutocapitalization(.none)

                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                }
                .padding(.horizontal)

                // Sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(Color.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                // Divider and OR Text
                HStack {
                    VStack { Divider () }
                    
                    Text("OR")
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    VStack { Divider() }
                }
                .padding(.vertical, 8)


                // Google Sign in
                
                Button {
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                            navigateToHome = true
                        } catch {
                            
                            print("DEBUG: Failed to sign in with Google with error \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Continue with Google")
                        .foregroundStyle(Color(.black))
                        .frame(width: UIScreen.main.bounds.width - 62, height:32)
                        .background(alignment: .leading) {
                            Image("Google")
                                .resizable()
                                .frame(width: 32, alignment: .center)
                        }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                // Sign up button
                NavigationLink(
                    destination: RegistrationView()
                        .navigationBarBackButtonHidden(true))
                {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
            .background(
                // Navigate to profile view when navigateToProfile is true
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                })
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
    
}

#Preview {
    LoginView()
}

//
//  AuthViewModel.swift
//  MedAlert
//
//  Created by Evan Best on 2024-05-18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import GoogleSignIn
import GoogleSignInSwift


protocol AuthenticationFormProtocol {
    var formIsValid : Bool { get }
}


@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            try await self.signIn(withEmail: email, password: password)
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut() // Sign out on backend
            self.userSession = nil // Sign out current session
            self.currentUser = nil // Wipe current user data model

        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            self.userSession?.delete { error in
                if let error = error {
                    print("DEBUG: Failed to delete user with error \(error.localizedDescription)")
                } else {
                    Firestore.firestore().collection("users").document(uid).delete()
                    self.currentUser = nil
                    self.userSession = nil
                }
            }
        }
    }
    

    func fetchUser() async {
        guard let user = Auth.auth().currentUser else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if uid == user.uid {
            // Check if the user signed in with Google
            if let providerData = user.providerData.first(where: { $0.providerID == GoogleAuthProviderID }) {
                // User signed in with Google, update currentUser directly
                self.currentUser = User(id: uid, fullname: providerData.displayName ?? "", email: providerData.email ?? "")
            } else {
                // User signed in with email and password, fetch user data from Firestore
                guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
                self.currentUser = try? snapshot.data(as: User.self)
            }
        }
    }

    
    func signInGoogle() async throws {
        
        guard let topVC = Utilites.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        // Call the signIn method of GIDSignIn.sharedInstance and await the result
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        // Retrieve the Google user's ID token and access token
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        // Create an AuthCredential using the retrieved tokens
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in with Firebase using the AuthCredential
        do {
            let result = try await Auth.auth().signIn(with: credential)
            // Handle successful sign-in
            self.userSession = result.user
            
            // Fetch user data
            await fetchUser()
            
            // Check if user exists in Firestore, if not, create user
            if self.currentUser == nil {
                let displayName = result.user.displayName ?? ""
                let email = result.user.email ?? ""
                try await createUser(withEmail: email, password: "", fullname: displayName)
            }
        } catch {
            // Handle sign-in failure
            print("DEBUG: Failed to sign in with Google with error \(error.localizedDescription)")
            throw error
        }
    }


    
}


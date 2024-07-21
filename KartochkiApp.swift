//
//  KartochkiApp.swift
//  Kartochki
//
//  Created by Darian Lee on 6/4/24.
//

import SwiftUI
import FirebaseCore

@main
struct KartochkiApp: App {

        
    @State private var authManager: AuthManager
        
        init() {
            FirebaseApp.configure()
            authManager = AuthManager()
     
        }

        var body: some Scene {
            WindowGroup {
                
                if authManager.user != nil {
                                DecksView()
                        .environment(authManager)
                            } else {
                                LoginView()
                                    .environment(authManager)
                            }
            }
        }
    }

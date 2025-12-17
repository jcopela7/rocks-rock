//
//  JonrocksApp.swift
//  jonrocks
//
//  Created by Jonathan Cope on 2025-10-18.
//

import SwiftUI

@main
struct jonrocksApp: App {
  @StateObject private var authService = AuthenticationService()

  var body: some Scene {
    WindowGroup {
      Group {
        if authService.isLoading {
          LoadingView()
        } else if authService.isAuthenticated {
          ContentView()
            .environmentObject(authService)
        } else {
          UnauthenticatedView(authService: authService)
        }
      }
      .onOpenURL { url in
        // Auth0 will handle the callback URL automatically
        // This ensures the app responds to the callback
        _ = url
      }
    }
  }
}

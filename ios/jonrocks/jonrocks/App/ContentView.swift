import Combine
import Foundation
import PhotosUI
import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      DiscoverView()
        .tabItem {
          Label("Discover", systemImage: "magnifyingglass")
        }

      AddView()
        .tabItem {
          Label("Add", systemImage: "plus.circle")
        }

      YouView()
        .tabItem {
          Label("You", systemImage: "person")
        }
    }
  }
}

#Preview {
  ContentView()
}

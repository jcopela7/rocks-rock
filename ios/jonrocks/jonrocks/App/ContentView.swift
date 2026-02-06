import Combine
import Foundation
import PhotosUI
import SwiftUI

struct ContentView: View {
  @State private var selectedTab = 0
  @State private var showClimbTypeDrawer = false
  @State private var selectedClimbType: ClimbFilter?

  private let addTabIndex = 1

  var body: some View {
    TabView(selection: $selectedTab) {
      DiscoverView()
        .tabItem {
          Label("Discover", systemImage: "magnifyingglass")
        }
        .tag(0)

      AddView(initialFilter: selectedClimbType ?? .boulder)
        .tabItem {
          Label("Add", systemImage: "plus.circle")
        }
        .tag(addTabIndex)

      YouView()
        .tabItem {
          Label("You", systemImage: "person")
        }
        .tag(2)
    }
    .onChange(of: selectedTab) { _, newValue in
      if newValue == addTabIndex {
        showClimbTypeDrawer = true
      }
    }
    .sheet(isPresented: $showClimbTypeDrawer) {
      ClimbTypeDrawer { climbType in
        selectedClimbType = climbType
        showClimbTypeDrawer = false
      }
      .presentationDetents([.height(400)])
      .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  ContentView()
}

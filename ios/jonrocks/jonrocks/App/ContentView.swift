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
    VStack(spacing: 0) {
      Group {
        if selectedTab == 0 {
          DiscoverView()
        } else if selectedTab == addTabIndex {
          AddView(initialFilter: selectedClimbType ?? .boulder)
        } else {
          YouView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      NavigationBar(
        selectedTab: $selectedTab,
        addTabIndex: addTabIndex,
        onAddTap: { showClimbTypeDrawer = true }
      )
    }
    .ignoresSafeArea(.keyboard)
    .sheet(isPresented: $showClimbTypeDrawer) {
      ClimbTypeDrawer { climbType in
        selectedClimbType = climbType
        selectedTab = addTabIndex
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

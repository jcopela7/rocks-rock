import Combine
import Foundation
import PhotosUI
import SwiftUI

struct ContentView: View {
  @State private var selectedTab = 0
  @State private var showClimbTypeDrawer = false
  @State private var selectedClimbType: ClimbFilter?
  @State private var sheetContentHeight: CGFloat = 400

  private let addTabIndex = 2

  var body: some View {
    VStack(spacing: 0) {
      Group {
        if selectedTab == 0 {
          DiscoverView()
        } else if selectedTab == 1 {
          MapView()
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
      .onPreferenceChange(SheetHeightPreferenceKey.self) { height in
        if height > 0 { sheetContentHeight = height + 34 }  // + bottom safe area
      }
      .presentationDetents([.height(sheetContentHeight)])
      .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  ContentView()
}

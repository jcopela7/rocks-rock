import SwiftUI

private struct ClimbTypeToAdd: Identifiable {
  let id = UUID()
  let filter: ClimbFilter
}

struct ContentView: View {
  @State private var selectedTab = 0
  @State private var showClimbTypeDrawer = false
  @State private var climbTypeToAdd: ClimbTypeToAdd?
  @State private var sheetContentHeight: CGFloat = 400
  @State private var locationToOpen: LocationDTO?

  var body: some View {
    VStack(spacing: 0) {
      Group {
        if selectedTab == 0 {
          DiscoverView(locationToOpen: $locationToOpen)
        } else if selectedTab == 1 {
          MapView(onLocationSelected: { location in
            selectedTab = 0
            locationToOpen = location
          })
        } else {
          YouView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      NavigationBar(
        selectedTab: $selectedTab,
        onAddTap: { showClimbTypeDrawer = true }
      )
    }
    .ignoresSafeArea(.keyboard)
    .sheet(isPresented: $showClimbTypeDrawer) {
      ClimbTypeDrawer { climbType in
        climbTypeToAdd = ClimbTypeToAdd(filter: climbType)
        showClimbTypeDrawer = false
      }
      .onPreferenceChange(SheetHeightPreferenceKey.self) { height in
        if height > 0 { sheetContentHeight = height + 34 }  // + bottom safe area
      }
      .presentationDetents([.height(sheetContentHeight)])
      .presentationDragIndicator(.visible)
    }
    .fullScreenCover(item: $climbTypeToAdd, onDismiss: { selectedTab = 0 }) { item in
      AddView(
        initialFilter: item.filter,
        onClose: { climbTypeToAdd = nil }
      )
    }
  }
}

#Preview {
  ContentView()
}

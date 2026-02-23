import SwiftUI

struct ContentView: View {
  @State private var selectedTab = 0
  @State private var showClimbTypeDrawer = false
  @State private var selectedClimbType: ClimbFilter?
  @State private var showClimbForm = false
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
        selectedClimbType = climbType
        showClimbTypeDrawer = false
        showClimbForm = true
      }
      .onPreferenceChange(SheetHeightPreferenceKey.self) { height in
        if height > 0 { sheetContentHeight = height + 34 }  // + bottom safe area
      }
      .presentationDetents([.height(sheetContentHeight)])
      .presentationDragIndicator(.visible)
    }
    .fullScreenCover(
      isPresented: $showClimbForm,
      onDismiss: {
        selectedClimbType = nil
        selectedTab = 0
      }
    ) {
      AddView(
        initialFilter: selectedClimbType ?? .boulder,
        onClose: { showClimbForm = false }
      )
    }
  }
}

#Preview {
  ContentView()
}

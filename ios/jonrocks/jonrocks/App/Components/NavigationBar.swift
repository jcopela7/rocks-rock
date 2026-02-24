import SwiftUI

struct NavigationBar: View {
  @Binding var selectedTab: Int
  let onAddTap: () -> Void

  var body: some View {
    HStack(spacing: 0) {
      NavigationBarButton(
        title: "Discover",
        systemImage: "magnifyingglass",
        isSelected: selectedTab == 0
      ) {
        selectedTab = 0
      }

      NavigationBarButton(
        title: "Map",
        systemImage: "map",
        isSelected: selectedTab == 1
      ) {
        selectedTab = 1
      }

      NavigationBarButton(
        title: "Add",
        systemImage: "plus.circle",
        isSelected: false
      ) {
        onAddTap()
      }

      NavigationBarButton(
        title: "You",
        systemImage: "person",
        isSelected: selectedTab == 3
      ) {
        selectedTab = 3
      }
    }
    .padding(.vertical, 8)
    .background {
      Rectangle()
        .fill(.white)
        .ignoresSafeArea(edges: .bottom)
    }
    .footerShadow()
  }
}

import SwiftUI

struct NavigationBar: View {
  @Binding var selectedTab: Int
  let addTabIndex: Int
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
        isSelected: selectedTab == addTabIndex
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
    .overlay(alignment: .top) {
      LinearGradient(
        colors: [
          Color.clear,
          Color.theme.textSecondary.opacity(0.08),
          Color.theme.textSecondary.opacity(0.15),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 8)
      .frame(maxWidth: .infinity)
      .offset(y: -8)
    }
  }
}

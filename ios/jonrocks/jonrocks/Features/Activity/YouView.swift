import SwiftUI

enum NavigationDestination: Hashable {
  case settings
}

struct YouView: View {
  @State private var selected = "Activity"
  @State private var ascentsVM: AscentsVM?
  @State private var discoverVM: DiscoverVM?
  @State private var navigationDestination: NavigationDestination?
  @EnvironmentObject var authService: AuthenticationService

  init() {
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.accent)
    UISegmentedControl.appearance().setTitleTextAttributes(
      [.foregroundColor: UIColor.white], for: .selected)
    UISegmentedControl.appearance().layer.cornerRadius = 2
    UISegmentedControl.appearance().clipsToBounds = true
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        AppHeader(
          title: "You",
          onSettingsTap: {
            navigationDestination = .settings
          },
          showSettingsButton: true
        )
        SegmentedPicker(
          selection: $selected,
          segments: ["Progress", "Activity"]
        )
        Group {
          if let ascentsVM = ascentsVM {
            if selected == "Progress" {
              ProgressViewTab(viewModel: ascentsVM)
            } else {
              ActivityListView(ascentsVM: ascentsVM)
            }
          } else {
            LoadingListView()
          }
        }
      }
      .navigationDestination(item: $navigationDestination) { destination in
        switch destination {
        case .settings:
          SettingsView(authService: authService)
            .environmentObject(authService)
        }
      }
    }
    .onAppear {
      if discoverVM == nil {
        discoverVM = DiscoverVM(authService: authService)
      }
      if ascentsVM == nil {
        ascentsVM = AscentsVM(authService: authService)
      }
    }
  }
}

#Preview {
  YouView()
}

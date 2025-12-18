import SwiftUI

struct YouView: View {
  @State private var selected = "Activity"
  @State private var ascentsVM: AscentsVM?
  @State private var discoverVM: DiscoverVM?
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
      VStack(spacing: 12) {
        AppHeader(
          title: "You",
          onAddTap: {
            Task {
              await authService.logout()
            }
          }, buttonLabel: "Log Out")
        SegmentedPicker(
          selection: $selected,
          segments: ["Progress", "Activity"]
        )
        .padding(.horizontal, 16)
        Group {
          if let ascentsVM = ascentsVM {
            if selected == "Progress" {
              ProgressViewTab(viewModel: ascentsVM)
            } else {
              ActivityLoggingView(ascentsVM: ascentsVM)
            }
          } else {
            LoadingListView()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

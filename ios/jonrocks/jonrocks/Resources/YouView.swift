import SwiftUI

struct YouView: View {
    @State private var selected = "Activity"
    @StateObject private var ascentsVM = AscentsVM()
    @StateObject private var discoverVM = DiscoverVM()
    @EnvironmentObject var authService: AuthenticationService

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.accent)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().layer.cornerRadius = 2
        UISegmentedControl.appearance().clipsToBounds = true
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "You", onAddTap: {
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
                    if selected == "Progress" {
                        ProgressViewTab(viewModel: ascentsVM)
                    } else {
                        ActivityLoggingView(ascentsVM: ascentsVM)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

#Preview {
    YouView()
}

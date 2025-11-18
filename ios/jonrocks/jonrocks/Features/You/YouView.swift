import SwiftUI

struct YouView: View {
    @State private var selected = "Activity"
    @StateObject private var ascentsVM = AscentsVM()
    @StateObject private var discoverVM = DiscoverVM()
    @State private var showingAddForm = false

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.accent)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().layer.cornerRadius = 2
        UISegmentedControl.appearance().clipsToBounds = true
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "You") {
                    showingAddForm = true
                }
                SegmentedPicker(
                    selection: $selected,
                    segments: ["Progress", "Activity"]
                )
                .padding(.horizontal, 16)
                Group {
                    if selected == "Progress" {
                        ProgressViewTab()
                    } else {
                        ActivityLoggingView(ascentsVM: ascentsVM)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .sheet(isPresented: $showingAddForm) {
                AddActivityFormView(ascentsVM: ascentsVM, discoverVM: discoverVM)
            }
        }
    }
}

#Preview {
    YouView()
}


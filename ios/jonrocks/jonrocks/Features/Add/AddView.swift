import SwiftUI

struct AddView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var discoverVM: DiscoverVM?
  @State private var ascentsVM: AscentsVM?
  @State private var selectedFilter: ClimbFilter

  init(initialFilter: ClimbFilter = .boulder) {
    _selectedFilter = State(initialValue: initialFilter)
  }

  var body: some View {
    VStack(spacing: 0) {
      AppHeader(title: "Add Activity", titleAlignment: .centered)
        .background(Color.theme.accent)
        .foregroundColor(Color.white)

      if selectedFilter == .boulder, let ascentsVM = ascentsVM, let discoverVM = discoverVM {
        BoulderingClimbForm(
          discoverVM: discoverVM,
          ascentsVM: ascentsVM
        )
      } else if selectedFilter == .sport, let ascentsVM = ascentsVM, let discoverVM = discoverVM {
        SportClimbForm(
          discoverVM: discoverVM,
          ascentsVM: ascentsVM
        )
      } else {
        Spacer()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.white)
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
  AddView()
}

import SwiftUI

struct AddView: View {
  @EnvironmentObject var authService: AuthenticationService
  @State private var discoverVM: DiscoverVM?
  @State private var ascentsVM: AscentsVM?
  @State private var selectedFilter: ClimbFilter

  var onClose: (() -> Void)?

  init(initialFilter: ClimbFilter = .boulder, onClose: (() -> Void)? = nil) {
    _selectedFilter = State(initialValue: initialFilter)
    self.onClose = onClose
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center) {
        Text("Add Activity")
          .font(.title2)
          .fontWeight(.bold)
        Spacer()
        if let onClose {
          Button(action: onClose) {
            Image(systemName: "xmark")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.white)
              .padding(8)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .background(Color.theme.accent)
      .foregroundColor(Color.white)

      if selectedFilter == .boulder, let ascentsVM = ascentsVM, let discoverVM = discoverVM {
        BoulderingClimbForm(
          discoverVM: discoverVM,
          ascentsVM: ascentsVM,
          onClose: onClose
        )
      } else if selectedFilter == .sport, let ascentsVM = ascentsVM, let discoverVM = discoverVM {
        SportClimbForm(
          discoverVM: discoverVM,
          ascentsVM: ascentsVM,
          onClose: onClose
        )
      } else if selectedFilter == .trad, let ascentsVM = ascentsVM, let discoverVM = discoverVM {
        TradClimbForm(
          discoverVM: discoverVM,
          ascentsVM: ascentsVM,
          onClose: onClose
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

import SwiftUI

struct AddView: View {
    @StateObject private var discoverVM = DiscoverVM()
    @StateObject private var ascentsVM = AscentsVM()
    @State private var selectedFilter: ClimbFilter = .boulder
    
    enum ClimbFilter {
        case boulder
        case trad
        case sport
        case board
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Add", onAddTap: nil)
            HStack(spacing: 24) {
                    FilterIconButton(
                        icon: "crashpadIcon",
                        title: "Boulder",
                        isActive: selectedFilter == .boulder,
                        action: { selectedFilter = .boulder }
                    )
                    FilterIconButton(
                        icon: "camIcon",
                        title: "Trad",
                        isActive: selectedFilter == .trad,
                        action: { selectedFilter = .trad }
                    )
                    FilterIconButton(
                        icon: "quickdrawIcon",
                        title: "Sport",
                        isActive: selectedFilter == .sport,
                        action: { selectedFilter = .sport }
                    )
                    FilterIconButton(
                        icon: "boardIcon",
                        title: "Board",
                        isActive: selectedFilter == .board,
                        action: { selectedFilter = .board }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            if selectedFilter == .boulder {
                BoulderingClimbForm(
                    discoverVM: discoverVM,
                    ascentsVM: ascentsVM
                )
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.theme.background)
        
    }
}

#Preview {
    AddView()
}


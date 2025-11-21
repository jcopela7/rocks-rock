import SwiftUI

struct AddView: View {
    var body: some View {
        VStack {
            AppHeader(title: "Add", onAddTap: nil)
            HStack(spacing: 24) {
                    FilterIconButton(
                        icon: "crashpadIcon",
                        title: "Boulder",
                        isActive: true,
                        action: {}
                    )
                    FilterIconButton(
                        icon: "camIcon",
                        title: "Trad",
                        isActive: false,
                        action: {}
                    )
                    FilterIconButton(
                        icon: "quickdrawIcon",
                        title: "Sport",
                        isActive: false,
                        action: {}
                    )
                    FilterIconButton(
                        icon: "boardIcon",
                        title: "Board",
                        isActive: false,
                        action: {}
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.theme.background)
        
    }
}

#Preview {
    AddView()
}


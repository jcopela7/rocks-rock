import SwiftUI

struct FilterButton: View {
    let title: String
    let icon: String?
    let isActive: Bool
    let action: () -> Void
    


    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isActive ? .white : Color.theme.textSecondary)
                        .frame(width: 20, height: 20)
                }
                Text(title) 
                    .fontWeight(.semibold)
                    .foregroundColor(isActive ? .white : Color.theme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.theme.accent : Color(.systemGray5))
            .clipShape(Capsule())
        }
    }
}

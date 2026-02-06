import SwiftUI

struct ClimbTypeDrawer: View {
  let onSelect: (ClimbFilter) -> Void

  var body: some View {
    VStack(spacing: 0) {
      RoundedRectangle(cornerRadius: 2.5)
        .fill(Color.theme.textSecondary.opacity(0.3))
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)

      Text("Log a climb")
        .font(.headline)
        .foregroundColor(Color.theme.textPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)

      Rectangle()
        .fill(Color.theme.textSecondary.opacity(0.3))
        .frame(height: 1)
        .padding(.horizontal, 16)

      VStack(spacing: 24) {
        ClimbTypeRow(icon: "crashpadIcon", title: "Boulder") {
          onSelect(.boulder)
        }
        ClimbTypeRow(icon: "camIcon", title: "Trad") {
          onSelect(.trad)
        }
        ClimbTypeRow(icon: "quickdrawIcon", title: "Sport") {
          onSelect(.sport)
        }
        ClimbTypeRow(icon: "boardIcon", title: "Board") {
          onSelect(.board)
        }
      }
      .padding(.horizontal, 4)
      .padding(.top, 24)

      Spacer(minLength: 0)
    }
    .background(Color.theme.background)
  }
}

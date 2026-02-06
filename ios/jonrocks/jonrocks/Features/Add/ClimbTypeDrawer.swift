import SwiftUI

struct ClimbTypeDrawer: View {
  let onSelect: (ClimbFilter) -> Void

  var body: some View {
    ZStack {
      Color.theme.background
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Text("Log a climb")
          .font(.headline)
          .foregroundColor(Color.theme.textPrimary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.vertical, 16)

        Rectangle()
          .fill(Color.theme.textSecondary.opacity(0.3))
          .frame(height: 1)

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
      }
      .fixedSize(horizontal: false, vertical: true)
      .background(
        GeometryReader { geo in
          Color.clear.preference(key: SheetHeightPreferenceKey.self, value: geo.size.height)
        }
      )
    }
  }
}

struct SheetHeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

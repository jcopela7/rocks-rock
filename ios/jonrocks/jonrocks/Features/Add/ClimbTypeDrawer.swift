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
        VStack(spacing: 4) {
          HStack(alignment: .center, spacing: 8) {
            Image("crashpadIcon")
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .foregroundColor(Color.theme.textSecondary)
            Text("Boulder")
              .font(.headline)
              .foregroundColor(Color.theme.textPrimary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
          }
        }
        VStack(spacing: 4) {
          HStack(alignment: .center, spacing: 8) {
            Image("camIcon")
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .foregroundColor(Color.theme.textSecondary)
            Text("Trad")
              .font(.headline)
              .foregroundColor(Color.theme.textPrimary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
          }
        }
        VStack(spacing: 4) {
          HStack(alignment: .center, spacing: 8) {
            Image("quickdrawIcon")
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .foregroundColor(Color.theme.textSecondary)
            Text("Sport")
              .font(.headline)
              .foregroundColor(Color.theme.textPrimary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
          }
        }
        VStack(spacing: 4) {
          HStack(alignment: .center, spacing: 8) {
            Image("boardIcon")
              .resizable()
              .scaledToFit()
              .frame(width: 36, height: 36)
              .foregroundColor(Color.theme.textSecondary)
            Text("Board")
              .font(.headline)
              .foregroundColor(Color.theme.textPrimary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 24)

      Spacer(minLength: 0)
    }
    .background(Color.theme.background)
  }
}

#Preview {
  ClimbTypeDrawer { _ in }
}

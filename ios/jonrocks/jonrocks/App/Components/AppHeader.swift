import SwiftUI

struct AppHeader: View {
  let title: String
  let onSettingsTap: (() -> Void)?
  let showSettingsButton: Bool?

  init(
    title: String,
    onSettingsTap: (() -> Void)? = nil,
    showSettingsButton: Bool? = nil
  ) {
    self.title = title
    self.onSettingsTap = onSettingsTap
    self.showSettingsButton = showSettingsButton
  }

  var body: some View {
    HStack {
      Text(title)
        .font(.largeTitle)
        .fontWeight(.bold)
      Spacer()
      HStack(spacing: 12) {
        if showSettingsButton ?? false, let onSettingsTap = onSettingsTap {
          Button(action: onSettingsTap) {
            Image(systemName: "gearshape")
              .fontWeight(.semibold)
              .frame(width: 24, height: 24)
              .clipShape(Circle())
              .foregroundColor(Color.theme.textPrimary)
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 8)
  }
}

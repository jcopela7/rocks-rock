import SwiftUI

enum AppHeaderTitleAlignment {
  case leading
  case centered
}

struct AppHeader: View {
  let title: String
  let onSettingsTap: (() -> Void)?
  let showSettingsButton: Bool?
  let titleAlignment: AppHeaderTitleAlignment

  init(
    title: String,
    onSettingsTap: (() -> Void)? = nil,
    showSettingsButton: Bool? = nil,
    titleAlignment: AppHeaderTitleAlignment = .leading
  ) {
    self.title = title
    self.onSettingsTap = onSettingsTap
    self.showSettingsButton = showSettingsButton
    self.titleAlignment = titleAlignment
  }

  var body: some View {
    ZStack {
      if titleAlignment == .centered {
        Text(title)
          .font(.title2)
          .fontWeight(.bold)
      }

      HStack {
        if titleAlignment == .leading {
          Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
        }
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
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 8)
  }
}

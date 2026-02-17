import SwiftUI

struct MapOverlayButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.92 : 1)
      .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
  }
}

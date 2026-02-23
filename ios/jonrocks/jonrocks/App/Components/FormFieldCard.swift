import SwiftUI

extension View {
  func formFieldCard() -> some View {
    self
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.theme.border, lineWidth: 1)
      )
  }
}

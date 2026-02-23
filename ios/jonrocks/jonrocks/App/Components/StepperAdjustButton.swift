import SwiftUI

struct StepperAdjustButton: View {
  let symbol: String
  let action: () -> Void
  var isDisabled: Bool = false

  var body: some View {
    Button(action: action) {
      Image(systemName: symbol)
    }
    .buttonStyle(StepperAdjustButtonStyle())
    .disabled(isDisabled)
  }
}

private struct StepperAdjustButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.system(size: 12, weight: .bold))
      .foregroundColor(Color.theme.textPrimary)
      .frame(
        width: configuration.isPressed ? 28 : 30,
        height: configuration.isPressed ? 28 : 30
      )
      .background(configuration.isPressed ? Color.raw.slate200 : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: configuration.isPressed ? 5 : 6))
      .overlay(
        RoundedRectangle(cornerRadius: configuration.isPressed ? 5 : 6)
          .stroke(Color.theme.border, lineWidth: 1)
      )
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
      .opacity(configuration.isPressed ? 0.95 : 1)
  }
}

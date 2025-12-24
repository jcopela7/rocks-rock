import SwiftUI

struct UnauthenticatedView: View {
  @ObservedObject var authService: AuthenticationService
  @State private var t = false

  var body: some View {
    ZStack {
      RadialGradient(
        colors: [
          Color.raw.fuchsia700.opacity(0.7),
          Color.raw.blue600.opacity(1),
        ],
        center: t ? .topLeading : .topTrailing,
        startRadius: 40,
        endRadius: 400
      )
      .ignoresSafeArea()
      .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: t)
      LinearGradient(
        colors: [
          Color.white.opacity(0.1),
          Color.black,
        ],
        startPoint: UnitPoint(x: 0.5, y: 0.2),
        endPoint: UnitPoint(x: 0.5, y: 0.5)
      )
      .ignoresSafeArea()
      VStack(spacing: 16) {
        Image("LogInLogo")
          .resizable()
          .scaledToFit()
          .frame(width: 300, height: 300)
          .foregroundColor(.white)
        Text("ESTEL")
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .cornerRadius(16)
        Text("An app for rock climbers by rock climbers")
          .font(.body)
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .padding()
          .cornerRadius(16)
          .padding()
        Button {
          Task {
            await authService.login()
          }
        } label: {
          Text("Log In")
            .font(.headline)
            .foregroundColor(Color.theme.textPrimary)
            .frame(maxWidth: 240)
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
            )
        }
        .disabled(authService.isLoading)
        .opacity(authService.isLoading ? 0.6 : 1)
        .padding()
      }
    }
    .onAppear { t = true }
  }
}

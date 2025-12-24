import SwiftUI

/// Loading/splash view used during authentication bootstrap.
/// Note: Named to avoid collision with the shared list/page `LoadingView`.
struct LoginLoadingView: View {
  @State private var t = false
  @State private var showContent = false

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color.raw.fuchsia700.opacity(0.5),
          Color.raw.blue600.opacity(1),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
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
      }
    }
  }
}

import SwiftUI

/// Loading/splash view used during authentication bootstrap.
/// Note: Named to avoid collision with the shared list/page `LoadingView`.
struct LoginLoadingView: View {
  @State private var t = false
  @State private var showContent = false

  var body: some View {
    ZStack {
      RadialGradient(
        colors: [
          Color.purple.opacity(0.45),
          Color.blue.opacity(0.70),
        ],
        center: t ? .topLeading : .topTrailing,
        startRadius: 40,
        endRadius: 600
      )
      .ignoresSafeArea()
      .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: t)

      VStack(spacing: 16) {
        Image("LogInLogo")
          .resizable()
          .scaledToFit()
          .frame(width: 300, height: 300)
          .foregroundColor(.white)
          .opacity(showContent ? 1 : 0)
          .animation(.easeIn(duration: 1), value: showContent)

        Text("ESTEL")
          .font(.largeTitle)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
          .cornerRadius(16)
          .opacity(showContent ? 1 : 0)
          .animation(.easeIn(duration: 1), value: showContent)
      }
    }
    .onAppear {
      t = true
      withAnimation(.easeIn(duration: 1)) {
        showContent = true
      }
    }
  }
}

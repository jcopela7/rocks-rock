import SwiftUI

struct UnauthenticatedView: View {
    @ObservedObject var authService: AuthenticationService
    @State private var t = false
    
    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.purple.opacity(0.45),
                    Color.blue.opacity(0.70)
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
            Text("ESTEL")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .cornerRadius(16)
            Text("Get started by signing in to your account")
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
                    .foregroundColor(Color.theme.accent)
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

import SwiftUI

struct UnauthenticatedView: View {
    @ObservedObject var authService: AuthenticationService
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Get started by signing in to your account")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            
            Button("Log In") {
                Task {
                    await authService.login()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(authService.isLoading)
        }
    }
}

import SwiftUI

struct AuthenticatedView: View {
    @ObservedObject var authService: AuthenticationService
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Successfully authenticated!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
            
            Text("Your Profile")
                .font(.title2)
                .fontWeight(.semibold)
        
            
            Button("Log Out") {
                Task {
                    await authService.logout()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(authService.isLoading)
        }
    }
}

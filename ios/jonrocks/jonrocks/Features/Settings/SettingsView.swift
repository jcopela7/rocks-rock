import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var authService: AuthenticationService
  @Environment(\.dismiss) var dismiss
  @StateObject private var userVM: UserVM
  
  init(authService: AuthenticationService) {
    _userVM = StateObject(wrappedValue: UserVM(authService: authService))
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if let user = userVM.user  {
        VStack(spacing: 16) {
          HStack {
              Text("Display Name")
                .foregroundColor(Color.theme.textPrimary)
              Spacer()
              Text(user.displayName)
                .foregroundColor(Color.theme.textSecondary)
            }
            HStack {
              Text("Email")
                .foregroundColor(Color.theme.textPrimary)
              Spacer()
              Text(user.email ?? "")
                .foregroundColor(Color.theme.textSecondary)
                .font(.system(.body, design: .monospaced))
            }
            }
      VStack(spacing: 16) {
        Button(action: {
              Task {
                await authService.logout()
                dismiss()
              }
            }) {
              HStack {
                Spacer()
                Text("Log Out")
                  .foregroundColor(Color.theme.danger)
                  .fontWeight(.semibold)
                Spacer()
              }
            }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding()
      }
        else {
        LoadingListView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .navigationTitle("Settings")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
          dismiss()
        }
      }
    }
    .task {
      await userVM.loadUser()
    }
  }
}


import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var authService: AuthenticationService
  @Environment(\.dismiss) var dismiss
  @StateObject private var userVM: UserVM

  init(authService: AuthenticationService) {
    _userVM = StateObject(wrappedValue: UserVM(authService: authService))
  }

  var body: some View {
    VStack(spacing: 16) {
      if let user = userVM.user {
        VStack {
          Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(Color.raw.slate200)
        }
        VStack(spacing: 16) {
          HStack(alignment: .center, spacing: 4) {
            Text("Display Name: ")
              .font(.system(.body))
              .foregroundColor(Color.theme.textPrimary)
            Text(user.displayName)
              .font(.system(.body))
              .foregroundColor(Color.theme.textSecondary)
          }
          HStack(alignment: .center, spacing: 4) {
            Text("Email: ")
              .font(.system(.body))
              .foregroundColor(Color.theme.textPrimary)
            Text(user.email ?? "placeholder@example.com")
              .font(.system(.body))
              .foregroundColor(Color.theme.textSecondary)
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
        .padding()
      } else {
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

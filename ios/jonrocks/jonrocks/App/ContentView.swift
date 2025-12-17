import Combine
import Foundation
import PhotosUI
import SwiftUI

struct AppHeader: View {
  let title: String
  let onAddTap: (() -> Void)?
  let buttonLabel: String?
  let buttonIcon: String?

  init(
    title: String, onAddTap: (() -> Void)? = nil, buttonLabel: String? = nil,
    buttonIcon: String? = nil
  ) {
    self.title = title
    self.onAddTap = onAddTap
    self.buttonLabel = buttonLabel ?? "Add"
    self.buttonIcon = buttonIcon ?? "plus"
  }

  var body: some View {
    HStack {
      Text(title)
        .font(.largeTitle)
        .fontWeight(.bold)
      Spacer()
      if let onAddTap = onAddTap {
        Button(action: onAddTap) {
          Label(buttonLabel ?? "Add", systemImage: buttonIcon ?? "plus")
            .fontWeight(.semibold)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color.theme.accent)
            .clipShape(Capsule())
            .foregroundColor(.white)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 8)
  }
}

struct ProgressView: View {
  var body: some View {
    VStack {
      Text("Your climbing progress and statistics will appear here.")
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }
}

struct ContentView: View {
  var body: some View {
    TabView {
      DiscoverView()
        .tabItem {
          Label("Discover", systemImage: "magnifyingglass")
        }

      AddView()
        .tabItem {
          Label("Add", systemImage: "plus.circle")
        }

      YouView()
        .tabItem {
          Label("You", systemImage: "person")
        }
    }
  }
}

#Preview {
  ContentView()
}

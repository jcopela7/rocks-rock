import Combine
import Foundation
import PhotosUI
import SwiftUI

struct AppHeader: View {
    let title: String
    let onAddTap: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
            Button(action: onAddTap) {
                Label("Add", systemImage: "plus")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.theme.accent)
                    .clipShape(Capsule())
                    .foregroundColor(.white)
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
    @State private var selected = "Activity"
    @StateObject private var vm = AscentsVM()
    @State private var showingAddForm = false

    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.theme.accent)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().layer.cornerRadius = 2
        UISegmentedControl.appearance().clipsToBounds = true
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                AppHeader(title: "You") {
                    showingAddForm = true
                }
                SegmentedPicker(
                    selection: $selected,
                    segments: ["Progress", "Activity"]
                )
                .padding(.horizontal, 16)
                Group {
                    if selected == "Progress" {
                        ProgressViewTab()
                    } else {
                        ActivityLoggingView(vm: vm)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .sheet(isPresented: $showingAddForm) {
                AddActivityFormView(viewModel: vm)
            }
        }
    }
}

#Preview {
    ContentView()
}

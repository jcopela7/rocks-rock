import SwiftUI

struct MapLayersButton: View {
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "square.stack.3d.up")
        .font(.title2)
        .foregroundStyle(Color.theme.accent)
        .padding(12)
        .background(.white)
        .clipShape(Circle())
        .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    }
    .buttonStyle(MapOverlayButtonStyle())
  }
}

import MapboxMaps
import SwiftUI

struct MapLocateMeButton: View {
  @Binding var viewport: Viewport

  var body: some View {
    Button {
      withViewportAnimation(.easeIn(duration: 0.5)) {
        viewport = .followPuck(zoom: 14, pitch: 0)
      }
    } label: {
      Image(systemName: "location.fill")
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

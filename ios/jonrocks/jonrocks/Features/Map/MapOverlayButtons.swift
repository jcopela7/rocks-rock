import SwiftUI

struct MapOverlayButtons<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        VStack {
          content
        }
        .padding(.bottom, 8)
        .padding(.trailing, 8)
      }
    }
  }
}

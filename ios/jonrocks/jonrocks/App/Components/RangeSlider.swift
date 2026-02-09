import SwiftUI

struct RangeSlider: View {
  @Binding var minValue: Double
  @Binding var maxValue: Double
  let range: ClosedRange<Double>
  let step: Double

  @State private var draggingMin: Bool = false
  @State private var draggingMax: Bool = false

  private let knobSize: CGFloat = 28
  private let trackHeight: CGFloat = 4

  var body: some View {
    GeometryReader { geometry in
      let trackWidth = geometry.size.width - knobSize
      let minPosition =
        CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth
      let maxPosition =
        CGFloat((maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * trackWidth

      ZStack(alignment: .leading) {
        // Background track
        RoundedRectangle(cornerRadius: 2)
          .fill(Color.theme.textSecondary.opacity(0.2))
          .frame(width: geometry.size.width * 0.95, height: trackHeight)
          .offset(x: knobSize / 2)

        // Active track (between knobs)
        RoundedRectangle(cornerRadius: 2)
          .fill(Color.theme.accent)
          .frame(width: max(0, maxPosition - minPosition), height: trackHeight)
          .offset(x: knobSize / 2 + minPosition)

        // Min knob
        Circle()
          .fill(Color.white)
          .frame(width: knobSize, height: knobSize)
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
          .overlay(
            Circle()
              .stroke(Color.theme.accent, lineWidth: 2)
          )
          .offset(x: minPosition)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                draggingMin = true
                let newPosition = max(0, min(value.location.x, maxPosition - knobSize))
                let newValue =
                  range.lowerBound + Double(newPosition / trackWidth)
                  * (range.upperBound - range.lowerBound)
                let steppedValue = round(newValue / step) * step
                minValue = max(range.lowerBound, min(steppedValue, maxValue - step))
              }
              .onEnded { _ in
                draggingMin = false
              }
          )

        // Max knob
        Circle()
          .fill(Color.white)
          .frame(width: knobSize, height: knobSize)
          .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
          .overlay(
            Circle()
              .stroke(Color.theme.accent, lineWidth: 2)
          )
          .offset(x: maxPosition)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                draggingMax = true
                let newPosition = max(minPosition + knobSize, min(value.location.x, trackWidth))
                let newValue =
                  range.lowerBound + Double(newPosition / trackWidth)
                  * (range.upperBound - range.lowerBound)
                let steppedValue = round(newValue / step) * step
                maxValue = max(minValue + step, min(steppedValue, range.upperBound))
              }
              .onEnded { _ in
                draggingMax = false
              }
          )
      }
      .frame(height: knobSize)
    }
    .frame(height: knobSize)
  }
}

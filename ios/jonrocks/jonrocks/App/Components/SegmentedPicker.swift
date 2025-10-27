import SwiftUI

struct SegmentedPicker<T: Hashable>: View {
    @Binding var selection: T
    let segments: [T]
    let title: (T) -> String

    // Animation
    @Namespace private var underlineAnimation

    // Layout
    var height: CGFloat = 36
    var underlineHeight: CGFloat = 3
    var spacing: CGFloat = 0

    // Colors (hook these to your theme)
    var backgroundColor: Color = .white // e.g. .white or .raw.slate50
    var underlineColor: Color = Color.theme.accent // e.g. .raw.blue500
    var textColor: Color = Color.theme.textSecondary // e.g. .raw.slate500
    var selectedTextColor: Color = Color.theme.textPrimary // e.g. .raw.slate900

    init(
        selection: Binding<T>,
        segments: [T],
        title: @escaping (T) -> String = { String(describing: $0) },
        backgroundColor: Color = .white,
        underlineColor: Color = Color.theme.accent,
        textColor: Color = Color.theme.textSecondary,
        selectedTextColor: Color = Color.theme.textPrimary
    ) {
        _selection = selection
        self.segments = segments
        self.title = title
        self.backgroundColor = backgroundColor
        self.underlineColor = underlineColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: spacing) {
                ForEach(segments, id: \.self) { item in
                    let isSelected = item == selection

                    VStack(spacing: 6) {
                        Text(title(item))
                            .fontWeight(.semibold)
                            .foregroundStyle(isSelected ? selectedTextColor : textColor)
                            .frame(maxWidth: .infinity, minHeight: height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selection = item
                                }
                                #if os(iOS)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                #endif
                            }

                        // Only draw underline for selected
                        if isSelected {
                            Rectangle()
                                .fill(underlineColor)
                                .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                                .frame(height: underlineHeight)
                        } else {
                            Rectangle()
                                .fill(Color.raw.slate100)
                                .frame(height: underlineHeight)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

import SwiftUI

extension Color {
    enum raw {
        // MARK: Slate

        static let slate50 = Color(hex: "#F8FAFC")
        static let slate100 = Color(hex: "#F1F5F9")
        static let slate200 = Color(hex: "#E2E8F0")
        static let slate300 = Color(hex: "#CBD5E1")
        static let slate400 = Color(hex: "#94A3B8")
        static let slate500 = Color(hex: "#64748B")
        static let slate600 = Color(hex: "#475569")
        static let slate700 = Color(hex: "#334155")
        static let slate800 = Color(hex: "#1E293B")
        static let slate900 = Color(hex: "#0F172A")

        // MARK: Gray

        static let gray50 = Color(hex: "#F9FAFB")
        static let gray100 = Color(hex: "#F3F4F6")
        static let gray200 = Color(hex: "#E5E7EB")
        static let gray300 = Color(hex: "#D1D5DB")
        static let gray400 = Color(hex: "#9CA3AF")
        static let gray500 = Color(hex: "#6B7280")
        static let gray600 = Color(hex: "#4B5563")
        static let gray700 = Color(hex: "#374151")
        static let gray800 = Color(hex: "#1F2937")
        static let gray900 = Color(hex: "#111827")

        // MARK: Zinc

        static let zinc50 = Color(hex: "#FAFAFA")
        static let zinc100 = Color(hex: "#F4F4F5")
        static let zinc200 = Color(hex: "#E4E4E7")
        static let zinc300 = Color(hex: "#D4D4D8")
        static let zinc400 = Color(hex: "#A1A1AA")
        static let zinc500 = Color(hex: "#71717A")
        static let zinc600 = Color(hex: "#52525B")
        static let zinc700 = Color(hex: "#3F3F46")
        static let zinc800 = Color(hex: "#27272A")
        static let zinc900 = Color(hex: "#18181B")

        // MARK: Neutral

        static let neutral50 = Color(hex: "#FAFAFA")
        static let neutral100 = Color(hex: "#F5F5F5")
        static let neutral200 = Color(hex: "#E5E5E5")
        static let neutral300 = Color(hex: "#D4D4D4")
        static let neutral400 = Color(hex: "#A3A3A3")
        static let neutral500 = Color(hex: "#737373")
        static let neutral600 = Color(hex: "#525252")
        static let neutral700 = Color(hex: "#404040")
        static let neutral800 = Color(hex: "#262626")
        static let neutral900 = Color(hex: "#171717")

        // MARK: Stone

        static let stone50 = Color(hex: "#FAFAF9")
        static let stone100 = Color(hex: "#F5F5F4")
        static let stone200 = Color(hex: "#E7E5E4")
        static let stone300 = Color(hex: "#D6D3D1")
        static let stone400 = Color(hex: "#A8A29E")
        static let stone500 = Color(hex: "#78716C")
        static let stone600 = Color(hex: "#57534E")
        static let stone700 = Color(hex: "#44403C")
        static let stone800 = Color(hex: "#292524")
        static let stone900 = Color(hex: "#1C1917")

        // MARK: Red

        static let red50 = Color(hex: "#FEF2F2")
        static let red100 = Color(hex: "#FEE2E2")
        static let red200 = Color(hex: "#FECACA")
        static let red300 = Color(hex: "#FCA5A5")
        static let red400 = Color(hex: "#F87171")
        static let red500 = Color(hex: "#EF4444")
        static let red600 = Color(hex: "#DC2626")
        static let red700 = Color(hex: "#B91C1C")
        static let red800 = Color(hex: "#991B1B")
        static let red900 = Color(hex: "#7F1D1D")

        // MARK: Orange

        static let orange50 = Color(hex: "#FFF7ED")
        static let orange100 = Color(hex: "#FFEDD5")
        static let orange200 = Color(hex: "#FED7AA")
        static let orange300 = Color(hex: "#FDBA74")
        static let orange400 = Color(hex: "#FB923C")
        static let orange500 = Color(hex: "#F97316")
        static let orange600 = Color(hex: "#EA580C")
        static let orange700 = Color(hex: "#C2410C")
        static let orange800 = Color(hex: "#9A3412")
        static let orange900 = Color(hex: "#7C2D12")

        // MARK: Amber

        static let amber50 = Color(hex: "#FFFBEB")
        static let amber100 = Color(hex: "#FEF3C7")
        static let amber200 = Color(hex: "#FDE68A")
        static let amber300 = Color(hex: "#FCD34D")
        static let amber400 = Color(hex: "#FBBF24")
        static let amber500 = Color(hex: "#F59E0B")
        static let amber600 = Color(hex: "#D97706")
        static let amber700 = Color(hex: "#B45309")
        static let amber800 = Color(hex: "#92400E")
        static let amber900 = Color(hex: "#78350F")

        // MARK: Yellow

        static let yellow50 = Color(hex: "#FEFCE8")
        static let yellow100 = Color(hex: "#FEF9C3")
        static let yellow200 = Color(hex: "#FEF08A")
        static let yellow300 = Color(hex: "#FDE047")
        static let yellow400 = Color(hex: "#FACC15")
        static let yellow500 = Color(hex: "#EAB308")
        static let yellow600 = Color(hex: "#CA8A04")
        static let yellow700 = Color(hex: "#A16207")
        static let yellow800 = Color(hex: "#854D0E")
        static let yellow900 = Color(hex: "#713F12")

        // MARK: Lime

        static let lime50 = Color(hex: "#F7FEE7")
        static let lime100 = Color(hex: "#ECFCCB")
        static let lime200 = Color(hex: "#D9F99D")
        static let lime300 = Color(hex: "#BEF264")
        static let lime400 = Color(hex: "#A3E635")
        static let lime500 = Color(hex: "#84CC16")
        static let lime600 = Color(hex: "#65A30D")
        static let lime700 = Color(hex: "#4D7C0F")
        static let lime800 = Color(hex: "#3F6212")
        static let lime900 = Color(hex: "#365314")

        // MARK: Green

        static let green50 = Color(hex: "#F0FDF4")
        static let green100 = Color(hex: "#DCFCE7")
        static let green200 = Color(hex: "#BBF7D0")
        static let green300 = Color(hex: "#86EFAC")
        static let green400 = Color(hex: "#4ADE80")
        static let green500 = Color(hex: "#22C55E")
        static let green600 = Color(hex: "#16A34A")
        static let green700 = Color(hex: "#15803D")
        static let green800 = Color(hex: "#166534")
        static let green900 = Color(hex: "#14532D")

        // MARK: Emerald

        static let emerald50 = Color(hex: "#ECFDF5")
        static let emerald100 = Color(hex: "#D1FAE5")
        static let emerald200 = Color(hex: "#A7F3D0")
        static let emerald300 = Color(hex: "#6EE7B7")
        static let emerald400 = Color(hex: "#34D399")
        static let emerald500 = Color(hex: "#10B981")
        static let emerald600 = Color(hex: "#059669")
        static let emerald700 = Color(hex: "#047857")
        static let emerald800 = Color(hex: "#065F46")
        static let emerald900 = Color(hex: "#064E3B")

        // MARK: Teal

        static let teal50 = Color(hex: "#F0FDFA")
        static let teal100 = Color(hex: "#CCFBF1")
        static let teal200 = Color(hex: "#99F6E4")
        static let teal300 = Color(hex: "#5EEAD4")
        static let teal400 = Color(hex: "#2DD4BF")
        static let teal500 = Color(hex: "#14B8A6")
        static let teal600 = Color(hex: "#0D9488")
        static let teal700 = Color(hex: "#0F766E")
        static let teal800 = Color(hex: "#115E59")
        static let teal900 = Color(hex: "#134E4A")

        // MARK: Cyan

        static let cyan50 = Color(hex: "#ECFEFF")
        static let cyan100 = Color(hex: "#CFFAFE")
        static let cyan200 = Color(hex: "#A5F3FC")
        static let cyan300 = Color(hex: "#67E8F9")
        static let cyan400 = Color(hex: "#22D3EE")
        static let cyan500 = Color(hex: "#06B6D4")
        static let cyan600 = Color(hex: "#0891B2")
        static let cyan700 = Color(hex: "#0E7490")
        static let cyan800 = Color(hex: "#155E75")
        static let cyan900 = Color(hex: "#164E63")

        // MARK: Sky

        static let sky50 = Color(hex: "#F0F9FF")
        static let sky100 = Color(hex: "#E0F2FE")
        static let sky200 = Color(hex: "#BAE6FD")
        static let sky300 = Color(hex: "#7DD3FC")
        static let sky400 = Color(hex: "#38BDF8")
        static let sky500 = Color(hex: "#0EA5E9")
        static let sky600 = Color(hex: "#0284C7")
        static let sky700 = Color(hex: "#0369A1")
        static let sky800 = Color(hex: "#075985")
        static let sky900 = Color(hex: "#0C4A6E")

        // MARK: Blue

        static let blue50 = Color(hex: "#EFF6FF")
        static let blue100 = Color(hex: "#DBEAFE")
        static let blue200 = Color(hex: "#BFDBFE")
        static let blue300 = Color(hex: "#93C5FD")
        static let blue400 = Color(hex: "#60A5FA")
        static let blue500 = Color(hex: "#3B82F6")
        static let blue600 = Color(hex: "#2563EB")
        static let blue700 = Color(hex: "#1D4ED8")
        static let blue800 = Color(hex: "#1E40AF")
        static let blue900 = Color(hex: "#1E3A8A")

        // MARK: Indigo

        static let indigo50 = Color(hex: "#EEF2FF")
        static let indigo100 = Color(hex: "#E0E7FF")
        static let indigo200 = Color(hex: "#C7D2FE")
        static let indigo300 = Color(hex: "#A5B4FC")
        static let indigo400 = Color(hex: "#818CF8")
        static let indigo500 = Color(hex: "#6366F1")
        static let indigo600 = Color(hex: "#4F46E5")
        static let indigo700 = Color(hex: "#4338CA")
        static let indigo800 = Color(hex: "#3730A3")
        static let indigo900 = Color(hex: "#312E81")

        // MARK: Violet

        static let violet50 = Color(hex: "#F5F3FF")
        static let violet100 = Color(hex: "#EDE9FE")
        static let violet200 = Color(hex: "#DDD6FE")
        static let violet300 = Color(hex: "#C4B5FD")
        static let violet400 = Color(hex: "#A78BFA")
        static let violet500 = Color(hex: "#8B5CF6")
        static let violet600 = Color(hex: "#7C3AED")
        static let violet700 = Color(hex: "#6D28D9")
        static let violet800 = Color(hex: "#5B21B6")
        static let violet900 = Color(hex: "#4C1D95")

        // MARK: Purple

        static let purple50 = Color(hex: "#FAF5FF")
        static let purple100 = Color(hex: "#F3E8FF")
        static let purple200 = Color(hex: "#E9D5FF")
        static let purple300 = Color(hex: "#D8B4FE")
        static let purple400 = Color(hex: "#C084FC")
        static let purple500 = Color(hex: "#A855F7")
        static let purple600 = Color(hex: "#9333EA")
        static let purple700 = Color(hex: "#7E22CE")
        static let purple800 = Color(hex: "#6B21A8")
        static let purple900 = Color(hex: "#581C87")

        // MARK: Fuchsia

        static let fuchsia50 = Color(hex: "#FDF4FF")
        static let fuchsia100 = Color(hex: "#FAE8FF")
        static let fuchsia200 = Color(hex: "#F5D0FE")
        static let fuchsia300 = Color(hex: "#F0ABFC")
        static let fuchsia400 = Color(hex: "#E879F9")
        static let fuchsia500 = Color(hex: "#D946EF")
        static let fuchsia600 = Color(hex: "#C026D3")
        static let fuchsia700 = Color(hex: "#A21CAF")
        static let fuchsia800 = Color(hex: "#86198F")
        static let fuchsia900 = Color(hex: "#701A75")

        // MARK: Pink

        static let pink50 = Color(hex: "#FDF2F8")
        static let pink100 = Color(hex: "#FCE7F3")
        static let pink200 = Color(hex: "#FBCFE8")
        static let pink300 = Color(hex: "#F9A8D4")
        static let pink400 = Color(hex: "#F472B6")
        static let pink500 = Color(hex: "#EC4899")
        static let pink600 = Color(hex: "#DB2777")
        static let pink700 = Color(hex: "#BE185D")
        static let pink800 = Color(hex: "#9D174D")
        static let pink900 = Color(hex: "#831843")

        // MARK: Rose

        static let rose50 = Color(hex: "#FFF1F2")
        static let rose100 = Color(hex: "#FFE4E6")
        static let rose200 = Color(hex: "#FECDD3")
        static let rose300 = Color(hex: "#FDA4AF")
        static let rose400 = Color(hex: "#FB7185")
        static let rose500 = Color(hex: "#F43F5E")
        static let rose600 = Color(hex: "#E11D48")
        static let rose700 = Color(hex: "#BE123C")
        static let rose800 = Color(hex: "#9F1239")
        static let rose900 = Color(hex: "#881337")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

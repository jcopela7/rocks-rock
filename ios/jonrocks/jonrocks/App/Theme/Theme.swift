import SwiftUI

extension Color {
  enum theme {
    static let background = Color.raw.slate50
    static let card = Color.raw.slate100
    static let textPrimary = Color.raw.slate900
    static let textSecondary = Color.raw.slate500
    static let accent = Color.raw.blue600
    static let success = Color.raw.green500
    static let warning = Color.raw.amber500
    static let danger = Color.raw.red500
    static let border = Color.raw.slate200
    static let shadow = Color.raw.slate800.opacity(0.1)
  }
}

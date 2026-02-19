import SwiftUI

struct SearchBar: View {
  @Binding var text: String
  var placeholder: String = "Search..."

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)

      TextField(placeholder, text: $text)
        .textFieldStyle(PlainTextFieldStyle())

      if !text.isEmpty {
        Button(action: {
          text = ""
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color(.white))
    .cornerRadius(10)
    .shadow(color: Color.theme.shadow, radius: 4, x: 0, y: 2)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.theme.border, lineWidth: 1)
    )
  }
}

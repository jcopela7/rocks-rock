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
  }
}

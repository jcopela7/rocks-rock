import UIKit

struct LocalImageRef: Codable, Hashable, Identifiable {
  let id: UUID
  let fileName: String  // e.g., "<uuid>.jpg"
  var fileURL: URL { LocalImageStore.imagesDir.appendingPathComponent(fileName) }
}

enum LocalImageStore {
  static let imagesDir: URL = {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!
    let dir = base.appendingPathComponent("Images", isDirectory: true)
    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir
  }()

  /// Saves a JPEG (quality 0.9) and returns a reference you can attach to an ascent
  static func saveJPEG(_ image: UIImage, quality: CGFloat = 0.9) throws -> LocalImageRef {
    let id = UUID()
    let fileName = "\(id.uuidString).jpg"
    let url = imagesDir.appendingPathComponent(fileName)
    guard let data = image.jpegData(compressionQuality: quality) else {
      throw NSError(
        domain: "LocalImageStore", code: -1,
        userInfo: [NSLocalizedDescriptionKey: "JPEG encode failed"])
    }
    try data.write(to: url, options: .atomic)
    return LocalImageRef(id: id, fileName: fileName)
  }

  static func load(_ ref: LocalImageRef) -> UIImage? {
    UIImage(contentsOfFile: ref.fileURL.path)
  }

  static func delete(_ ref: LocalImageRef) {
    try? FileManager.default.removeItem(at: ref.fileURL)
  }
}

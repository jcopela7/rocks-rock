import Foundation

enum AppConfig {
  static var apiBaseURL: URL = {
    guard let str = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
      let url = URL(string: str)
    else {
      fatalError("API_BASE_URL missing or invalid")
    }
    return url
  }()
}

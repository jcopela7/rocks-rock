import Foundation

enum AuthConfig {
    static var clientId: String = {
        guard let path = Bundle.main.path(forResource: "Auth", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["ClientID"] as? String
        else {
            fatalError("Auth.plist missing or ClientID not found")
        }
        return clientId
    }()
    
    static var domain: String = {
        guard let path = Bundle.main.path(forResource: "Auth", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let domain = plist["Domain"] as? String
        else {
            fatalError("Auth.plist missing or Domain not found")
        }
        return domain
    }()
}




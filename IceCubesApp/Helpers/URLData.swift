import Foundation

extension Data {
  func base64UrlEncodedString() -> String {
    /// Base64 URL エンコーディングされた文字列を返します。
    /// 通常の Base64 エンコーディングから "+" と "/" をそれぞれ "-" と "_" に置換し、
    /// 末尾の "=" を削除して URL で安全に使用できる形式にします。
    base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

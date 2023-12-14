import Foundation

public struct StatusContext: Decodable {
  public let ancestors: [ModelsStatus]
  public let descendants: [ModelsStatus]

  public static func empty() -> StatusContext {
    .init(ancestors: [], descendants: [])
  }
}

extension StatusContext: Sendable {}

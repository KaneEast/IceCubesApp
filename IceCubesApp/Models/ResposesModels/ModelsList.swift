import Foundation

public struct ModelsList: Codable, Identifiable, Equatable, Hashable {
  public let id: String
  public let title: String
  public let repliesPolicy: String
}

extension ModelsList: Sendable {}

import Foundation

import SwiftUI

@MainActor
public class StatusEmbedCache {
  public static let shared = StatusEmbedCache()

  private var cache: [URL: ModelsStatus] = [:]

  public var badStatusesURLs = Set<URL>()

  private init() {}

  public func set(url: URL, status: ModelsStatus) {
    cache[url] = status
  }

  public func get(url: URL) -> ModelsStatus? {
    cache[url]
  }
}

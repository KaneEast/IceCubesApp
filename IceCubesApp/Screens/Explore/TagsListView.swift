

import SwiftUI

public struct TagsListView: View {
  @Environment(Theme.self) private var theme

  let tags: [Tag]

  public init(tags: [Tag]) {
    self.tags = tags
  }

  public var body: some View {
    List {
      ForEach(tags) { tag in
        TagRowView(tag: tag)
          .listRowBackground(Color.white)
          .padding(.vertical, 4)
      }
    }
    .scrollContentBackground(.hidden)
    .background(Color.white)
    .listStyle(.plain)
    .navigationTitle("explore.section.trending.tags")
    .navigationBarTitleDisplayMode(.inline)
  }
}

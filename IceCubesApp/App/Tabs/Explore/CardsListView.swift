


import SwiftUI

public struct CardsListView: View {
  @Environment(Theme.self) private var theme

  let cards: [Card]

  public init(cards: [Card]) {
    self.cards = cards
  }

  public var body: some View {
    List {
      ForEach(cards) { card in
        StatusRowCardView(card: card)
          .listRowBackground(Color.white)
          .padding(.vertical, 8)
      }
    }
    .scrollContentBackground(.hidden)
    .background(Color.white)
    .listStyle(.plain)
    .navigationTitle("explore.section.trending.links")
    .navigationBarTitleDisplayMode(.inline)
  }
}

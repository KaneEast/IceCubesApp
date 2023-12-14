

import SwiftUI

struct StatusRowSpoilerView: View {
  let status: AnyStatus
  @Binding var displaySpoiler: Bool

  var body: some View {
    HStack(alignment: .top) {
      Text("⚠︎")
        .font(.system(.subheadline, weight: .bold))
        .foregroundColor(.secondary)
      EmojiTextApp(status.spoilerText, emojis: status.emojis, language: status.language)
        .font(.system(.subheadline, weight: .bold))
        .emojiSize(Font.scaledSubheadlineFont.emojiSize)
        .emojiBaselineOffset(Font.scaledSubheadlineFont.emojiBaselineOffset)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
      Spacer()
      Button {
        withAnimation {
          displaySpoiler.toggle()
        }
      } label: {
        Image(systemName: "chevron.down")
          .rotationEffect(Angle(degrees: displaySpoiler ? 0 : 180))
      }
      .buttonStyle(.bordered)
    }
    .contentShape(Rectangle())
    .onTapGesture { // make whole row tapable to make up for smaller button size
      withAnimation {
        displaySpoiler.toggle()
      }
    }
  }
}
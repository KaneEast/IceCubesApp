import SwiftUI

@MainActor
public struct StatusEmbeddedView: View {
  @Environment(Theme.self) private var theme

  public let status: ModelsStatus
  public let client: Client
  public let routerPath: RouterPath

  public init(status: ModelsStatus, client: Client, routerPath: RouterPath) {
    self.status = status
    self.client = client
    self.routerPath = routerPath
  }

  public var body: some View {
    HStack {
      VStack(alignment: .leading) {
        makeAccountView(account: status.reblog?.account ?? status.account)
        StatusRowView(viewModel: .init(status: status,
                                       client: client,
                                       routerPath: routerPath,
                                       showActions: false))
          .accessibilityLabel(status.content.asRawText)
          .environment(\.isCompact, true)
          .environment(\.isStatusFocused, false)
      }
      Spacer()
    }
    .padding(8)
    .cornerRadius(4)
    .overlay(
      RoundedRectangle(cornerRadius: 4)
        .stroke(.gray.opacity(0.35), lineWidth: 1)
    )
    .padding(.top, 8)
  }

  private func makeAccountView(account: Account) -> some View {
    HStack(alignment: .center) {
      AvatarView(url: account.avatar, size: .embed)
      VStack(alignment: .leading, spacing: 0) {
        EmojiTextApp(.init(stringValue: account.safeDisplayName), emojis: account.emojis)
          .font(.scaledFootnote)
          .emojiSize(Font.scaledFootnoteFont.emojiSize)
          .emojiBaselineOffset(Font.scaledFootnoteFont.emojiBaselineOffset)
          .fontWeight(.semibold)
        Group {
          Text("@\(account.acct)") +
            Text(" ⸱ ") +
            Text(status.reblog?.createdAt.relativeFormatted ?? status.createdAt.relativeFormatted)
        }
        .font(.scaledCaption)
        .foregroundColor(.gray)
      }
    }
  }
}
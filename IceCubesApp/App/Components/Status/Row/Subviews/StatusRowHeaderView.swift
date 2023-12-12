import SwiftUI

@MainActor
struct StatusRowHeaderView: View {
  @Environment(\.isInCaptureMode) private var isInCaptureMode: Bool
  @Environment(\.isStatusFocused) private var isFocused
  
  @Environment(Theme.self) private var theme
  
  let viewModel: StatusRowViewModel
  
  var body: some View {
    HStack(alignment: .center) {
      Button {
        viewModel.navigateToAccountDetail(account: viewModel.finalStatus.account)
      } label: {
        accountView
      }
      .buttonStyle(.plain)
      Spacer()
      if !isInCaptureMode {
        threadIcon
        contextMenuButton
      }
    }
  }
  
  @ViewBuilder
  private var accountView: some View {
    HStack(alignment: .center) {
      AvatarView(url: viewModel.finalStatus.account.avatar, size: .status)
      VStack(alignment: .leading, spacing: 2) {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
          Group {
            EmojiTextApp(.init(stringValue: viewModel.finalStatus.account.safeDisplayName),
                         emojis: viewModel.finalStatus.account.emojis)
            .font(.scaledSubheadline)
            .foregroundColor(theme.labelColor)
            .emojiSize(Font.scaledSubheadlineFont.emojiSize)
            .emojiBaselineOffset(Font.scaledSubheadlineFont.emojiBaselineOffset)
            .fontWeight(.semibold)
            .lineLimit(1)
            accountBadgeView
              .font(.footnote)
          }
          .layoutPriority(1)
          Text("@\(theme.displayFullUsername ? viewModel.finalStatus.account.acct : viewModel.finalStatus.account.username)")
            .font(.scaledFootnote)
            .foregroundColor(.gray)
            .lineLimit(1)
        }
        dateView
          .font(.scaledFootnote)
          .foregroundColor(.gray)
          .lineLimit(1)
      }
    }
  }
  
  private var accountBadgeView: Text {
    if (viewModel.status.reblogAsAsStatus ?? viewModel.status).account.bot {
      return Text(Image(systemName: "poweroutlet.type.b.fill")) + Text(" ")
    } else if (viewModel.status.reblogAsAsStatus ?? viewModel.status).account.locked {
      return Text(Image(systemName: "lock.fill")) + Text(" ")
    }
    return Text("")
  }
  
  private var dateView: Text {
    Text(viewModel.finalStatus.createdAt.relativeFormatted) +
    Text(" ⸱ ") +
    Text(Image(systemName: viewModel.finalStatus.visibility.iconName))
  }
  
  @ViewBuilder
  private var threadIcon: some View {
    if viewModel.isThread {
      Image(systemName: "bubble.left.and.bubble.right")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 15)
        .foregroundColor(.gray)
    }
  }
  
  private var contextMenuButton: some View {
    Menu {
      StatusRowContextMenu(viewModel: viewModel)
        .onAppear {
          Task {
            await viewModel.loadAuthorRelationship()
          }
        }
    } label: {
      Image(systemName: "ellipsis")
        .frame(width: 40, height: 40)
    }
    .menuStyle(.borderlessButton)
    .foregroundColor(.gray)
    .contentShape(Rectangle())
  }
}

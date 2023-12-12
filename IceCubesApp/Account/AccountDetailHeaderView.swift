



import NukeUI

import SwiftUI

@MainActor
struct AccountDetailHeaderView: View {
  enum Constants {
    static let headerHeight: CGFloat = 200
  }

  @Environment(Theme.self) private var theme
  @Environment(QuickLook.self) private var quickLook
  @Environment(RouterPath.self) private var routerPath
  @Environment(CurrentAccount.self) private var currentAccount
  @Environment(\.redactionReasons) private var reasons
  @Environment(\.isSupporter) private var isSupporter: Bool

  var viewModel: AccountDetailViewModel
  let account: Account
  let scrollViewProxy: ScrollViewProxy?

  var body: some View {
    VStack(alignment: .leading) {
      ZStack(alignment: .bottomTrailing) {
        Rectangle()
          .frame(height: Constants.headerHeight)
          .overlay {
            headerImageView
          }
        if viewModel.relationship?.followedBy == true {
          Text("account.relation.follows-you")
            .font(.scaledFootnote)
            .fontWeight(.semibold)
            .padding(4)
            .background(.ultraThinMaterial)
            .cornerRadius(4)
            .padding(8)
        }
      }
      accountInfoView
    }
  }

  private var headerImageView: some View {
    ZStack(alignment: .bottomTrailing) {
      if reasons.contains(.placeholder) {
        Rectangle()
          .foregroundColor(.gray)
          .frame(height: Constants.headerHeight)
      } else {
        LazyImage(url: account.header) { state in
          if let image = state.image {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .overlay(account.haveHeader ? .black.opacity(0.50) : .clear)
              .frame(height: Constants.headerHeight)
              .clipped()
          } else if state.isLoading {
            Color.gray
              .frame(height: Constants.headerHeight)
              .shimmering()
          } else {
            Color.gray
              .frame(height: Constants.headerHeight)
          }
        }
        .frame(height: Constants.headerHeight)
      }
    }
    .background(.gray)
    .frame(height: Constants.headerHeight)
    .onTapGesture {
      guard account.haveHeader else {
        return
      }
      let attachement = MediaAttachment.imageWith(url: account.header)
      quickLook.prepareFor(selectedMediaAttachment: attachement, mediaAttachments: [attachement])
    }
  }

  private var accountAvatarView: some View {
    HStack {
      ZStack(alignment: .topTrailing) {
        AvatarView(url: account.avatar, size: .account)
        if viewModel.isCurrentUser, isSupporter {
          Image(systemName: "checkmark.seal.fill")
            .resizable()
            .frame(width: 25, height: 25)
            .foregroundColor(theme.tintColor)
            .offset(x: theme.avatarShape == .circle ? 0 : 10,
                    y: theme.avatarShape == .circle ? 0 : -10)
        }
      }
      .onTapGesture {
        guard account.haveAvatar else {
          return
        }
        let attachement = MediaAttachment.imageWith(url: account.avatar)
        quickLook.prepareFor(selectedMediaAttachment: attachement, mediaAttachments: [attachement])
      }

      Spacer()
      Group {
        Button {
          withAnimation {
            scrollViewProxy?.scrollTo("status", anchor: .top)
          }
        } label: {
          makeCustomInfoLabel(title: "account.posts", count: account.statusesCount ?? 0)
        }
        .buttonStyle(.borderless)

        Button {
          routerPath.navigate(to: .following(id: account.id))
        } label: {
          makeCustomInfoLabel(title: "account.following", count: account.followingCount ?? 0)
        }
        .buttonStyle(.borderless)

        Button {
          routerPath.navigate(to: .followers(id: account.id))
        } label: {
          makeCustomInfoLabel(
            title: "account.followers",
            count: account.followersCount ?? 0,
            needsBadge: currentAccount.account?.id == account.id && !currentAccount.followRequests.isEmpty
          )
        }
        .buttonStyle(.borderless)

      }.offset(y: 20)
    }
  }

  private var accountInfoView: some View {
    Group {
      accountAvatarView
      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 0) {
          HStack(alignment: .center, spacing: 2) {
            EmojiTextApp(.init(stringValue: account.safeDisplayName), emojis: account.emojis)
              .font(.scaledHeadline)
              .foregroundColor(theme.labelColor)
              .emojiSize(Font.scaledHeadlineFont.emojiSize)
              .emojiBaselineOffset(Font.scaledHeadlineFont.emojiBaselineOffset)

            // The views here are wrapped in ZStacks as a Text(Image) does not provide an `accessibilityLabel`.
            if account.bot {
              ZStack {
                Text(Image(systemName: "poweroutlet.type.b.fill"))
                  .font(.footnote)
              }
            }
            if account.locked {
              ZStack {
                Text(Image(systemName: "lock.fill"))
                  .font(.footnote)
              }
            }
            if viewModel.relationship?.blocking == true {
              ZStack {
                Text(Image(systemName: "person.crop.circle.badge.xmark.fill"))
                  .font(.footnote)
              }
            }
            if viewModel.relationship?.muting == true {
              ZStack {
                Text(Image(systemName: "speaker.slash.fill"))
                  .font(.footnote)
              }
            }
          }
          Text("@\(account.acct)")
            .font(.scaledCallout)
            .foregroundColor(.gray)
            .textSelection(.enabled)
          joinedAtView
        }

        Spacer()
        if let relationship = viewModel.relationship, !viewModel.isCurrentUser {
          HStack {
            FollowButton(viewModel: .init(accountId: account.id,
                                          relationship: relationship,
                                          shouldDisplayNotify: true,
                                          relationshipUpdated: { relationship in
                                            viewModel.relationship = relationship
                                          }))
          }
        }
      }

      if let note = viewModel.relationship?.note, !note.isEmpty,
         !viewModel.isCurrentUser
      {
        makeNoteView(note)
      }

      EmojiTextApp(account.note, emojis: account.emojis)
        .font(.scaledBody)
        .foregroundColor(theme.labelColor)
        .emojiSize(Font.scaledBodyFont.emojiSize)
        .emojiBaselineOffset(Font.scaledBodyFont.emojiBaselineOffset)
        .padding(.top, 8)
        .textSelection(.enabled)
        .environment(\.openURL, OpenURLAction { url in
          routerPath.handle(url: url)
        })

      if let translation = viewModel.translation, !viewModel.isLoadingTranslation {
        GroupBox {
          VStack(alignment: .leading, spacing: 4) {
            Text(translation.content.asSafeMarkdownAttributedString)
              .font(.scaledBody)
            Text(getLocalizedStringLabel(langCode: translation.detectedSourceLanguage, provider: translation.provider))
              .font(.footnote)
              .foregroundColor(.gray)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
      }

      fieldsView
    }
    .padding(.horizontal, .layoutPadding)
    .offset(y: -40)
  }

  private func getLocalizedStringLabel(langCode: String, provider: String) -> String {
    if let localizedLanguage = Locale.current.localizedString(forLanguageCode: langCode) {
      let format = NSLocalizedString("status.action.translated-label-from-%@-%@", comment: "")
      return String.localizedStringWithFormat(format, localizedLanguage, provider)
    } else {
      return "status.action.translated-label-\(provider)"
    }
  }

  private func makeCustomInfoLabel(title: LocalizedStringKey, count: Int, needsBadge: Bool = false) -> some View {
    VStack {
      Text(count, format: .number.notation(.compactName))
        .font(.scaledHeadline)
        .foregroundColor(theme.tintColor)
        .overlay(alignment: .trailing) {
          if needsBadge {
            Circle()
              .fill(Color.red)
              .frame(width: 9, height: 9)
              .offset(x: 12)
          }
        }
      Text(title)
        .font(.scaledFootnote)
        .foregroundColor(.gray)
    }
  }

  @ViewBuilder
  private var joinedAtView: some View {
    if let joinedAt = viewModel.account?.createdAt.asDate {
      HStack(spacing: 4) {
        Image(systemName: "calendar")
        Text("account.joined")
        Text(joinedAt, style: .date)
      }
      .foregroundColor(.gray)
      .font(.footnote)
      .padding(.top, 6)
    }
  }

  @ViewBuilder
  private func makeNoteView(_ note: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("account.relation.note.label")
        .foregroundColor(.gray)
      Text(note)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.gray)
        .cornerRadius(4)
        .overlay(
          RoundedRectangle(cornerRadius: 4)
            .stroke(.gray.opacity(0.35), lineWidth: 1)
        )
    }
  }

  @ViewBuilder
  private var fieldsView: some View {
    if !viewModel.fields.isEmpty {
      VStack(alignment: .leading) {
        ForEach(viewModel.fields) { field in
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              EmojiTextApp(.init(stringValue: field.name), emojis: viewModel.account?.emojis ?? [])
                .emojiSize(Font.scaledHeadlineFont.emojiSize)
                .emojiBaselineOffset(Font.scaledHeadlineFont.emojiBaselineOffset)
                .font(.scaledHeadline)
              HStack {
                if field.verifiedAt != nil {
                  Image(systemName: "checkmark.seal")
                    .foregroundColor(Color.green.opacity(0.80))
                }
                EmojiTextApp(field.value, emojis: viewModel.account?.emojis ?? [])
                  .emojiSize(Font.scaledBodyFont.emojiSize)
                  .emojiBaselineOffset(Font.scaledBodyFont.emojiBaselineOffset)
                  .foregroundColor(theme.tintColor)
                  .environment(\.openURL, OpenURLAction { url in
                    routerPath.handle(url: url)
                  })
              }
              .font(.scaledBody)
              if viewModel.fields.last != field {
                Divider()
                  .padding(.vertical, 4)
              }
            }
            Spacer()
          }
          .modifier(ConditionalUserDefinedFieldAccessibilityActionModifier(field: field, routerPath: routerPath))
        }
      }
      .padding(8)
      .background(.gray)
      .cornerRadius(4)
      .overlay(
        RoundedRectangle(cornerRadius: 4)
          .stroke(.gray.opacity(0.35), lineWidth: 1)
      )
    }
  }
}

/// A ``ViewModifier`` that creates a attaches an accessibility action if the field value is a valid link
private struct ConditionalUserDefinedFieldAccessibilityActionModifier: ViewModifier {
  let field: Account.Field
  let routerPath: RouterPath

  func body(content: Content) -> some View {
    if let url = URL(string: field.value.asRawText), UIApplication.shared.canOpenURL(url) {
      content
    } else {
      content
    }
  }
}

struct AccountDetailHeaderView_Previews: PreviewProvider {
  static var previews: some View {
    AccountDetailHeaderView(viewModel: .init(account: .placeholder()),
                            account: .placeholder(),
                            scrollViewProxy: nil)
  }
}

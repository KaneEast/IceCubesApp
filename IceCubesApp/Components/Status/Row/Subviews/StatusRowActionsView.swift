



import SwiftUI

@MainActor
struct StatusRowActionsView: View {
  @Environment(Theme.self) private var theme
  @Environment(CurrentAccount.self) private var currentAccount
  @Environment(StatusDataController.self) private var statusDataController
  @Environment(UserPreferences.self) private var userPreferences

  @Environment(\.isStatusFocused) private var isFocused

  var viewModel: StatusRowViewModel

  func privateBoost() -> Bool {
    viewModel.status.visibility == .priv && viewModel.status.account.id == currentAccount.account?.id
  }

  @MainActor
  enum Action: CaseIterable {
    case respond, boost, favorite, bookmark, share

    // Have to implement this manually here due to compiler not implicitly
    // inserting `nonisolated`, which leads to a warning:
    //
    //     Main actor-isolated static property 'allCases' cannot be used to
    //     satisfy nonisolated protocol requirement
    //
    public nonisolated static var allCases: [StatusRowActionsView.Action] {
      [.respond, .boost, .favorite, .bookmark, .share]
    }

    func image(dataController: StatusDataController, privateBoost: Bool = false) -> Image {
      switch self {
      case .respond:
        return Image(systemName: "arrowshape.turn.up.left")
      case .boost:
        if privateBoost {
          if dataController.isReblogged {
            return Image("Rocket.Fill")
          } else {
            return Image(systemName: "lock.rotation")
          }
        }
        return Image(dataController.isReblogged ? "Rocket.Fill" : "Rocket")
      case .favorite:
        return Image(systemName: dataController.isFavorited ? "star.fill" : "star")
      case .bookmark:
        return Image(systemName: dataController.isBookmarked ? "bookmark.fill" : "bookmark")
      case .share:
        return Image(systemName: "square.and.arrow.up")
      }
    }

    func count(dataController: StatusDataController, isFocused: Bool, theme: Theme) -> Int? {      
      switch self {
      case .respond:
        return dataController.repliesCount
      case .favorite:
        return dataController.favoritesCount
      case .boost:
        return dataController.reblogsCount
      case .share, .bookmark:
        return nil
      }
    }

    func tintColor(theme: Theme) -> Color? {
      switch self {
      case .respond, .share:
        nil
      case .favorite:
        .yellow
      case .bookmark:
        .pink
      case .boost:
        theme.tintColor
      }
    }

    func isOn(dataController: StatusDataController) -> Bool {
      switch self {
      case .respond, .share: false
      case .favorite: dataController.isFavorited
      case .bookmark: dataController.isBookmarked
      case .boost: dataController.isReblogged
      }
    }
  }

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        ForEach(Action.allCases, id: \.self) { action in
          if action == .share {
            if let urlString = viewModel.finalStatus.url,
               let url = URL(string: urlString)
            {
              switch userPreferences.shareButtonBehavior {
              case .linkOnly:
                ShareLink(item: url) {
                  action.image(dataController: statusDataController)
                }
                .buttonStyle(.statusAction())
              case .linkAndText:
                ShareLink(item: url,
                          subject: Text(viewModel.finalStatus.account.safeDisplayName),
                          message: Text(viewModel.finalStatus.content.asRawText))
                {
                  action.image(dataController: statusDataController)
                }
                .buttonStyle(.statusAction())
              }
            }
          } else {
            actionButton(action: action)
            Spacer()
          }
        }
      }
    }
  }

  private func actionButton(action: Action) -> some View {
    HStack(spacing: 2) {
      Button {
        handleAction(action: action)
      } label: {
        if action == .boost {
          action
            .image(dataController: statusDataController, privateBoost: privateBoost())
            .imageScale(.medium)
            .font(.body)
            .fontWeight(.black)
        } else {
          action
            .image(dataController: statusDataController, privateBoost: privateBoost())
        }
      }
      .buttonStyle(
        .statusAction(
          isOn: action.isOn(dataController: statusDataController),
          tintColor: action.tintColor(theme: theme)
        )
      )
      .disabled(action == .boost &&
        (viewModel.status.visibility == .direct || viewModel.status.visibility == .priv && viewModel.status.account.id != currentAccount.account?.id))
      if let count = action.count(dataController: statusDataController,
                                  isFocused: isFocused,
                                  theme: theme), !viewModel.isRemote
      {
        Text("\(count)")
          .foregroundColor(Color(UIColor.secondaryLabel))
          .font(.scaledFootnote)
          .monospacedDigit()
      }
    }
  }

  private func handleAction(action: Action) {
    Task {
      if viewModel.isRemote, viewModel.localStatusId == nil || viewModel.localStatus == nil {
        guard await viewModel.fetchRemoteStatus() else {
          return
        }
      }
      HapticManager.shared.fireHaptic(of: .notification(.success))
      switch action {
      case .respond:
        SoundEffectManager.shared.playSound(of: .share)
        viewModel.routerPath.presentedSheet = .replyToStatusEditor(status: viewModel.localStatus ?? viewModel.status)
      case .favorite:
        SoundEffectManager.shared.playSound(of: .favorite)
        await statusDataController.toggleFavorite(remoteStatus: viewModel.localStatusId)
      case .bookmark:
        SoundEffectManager.shared.playSound(of: .bookmark)
        await statusDataController.toggleBookmark(remoteStatus: viewModel.localStatusId)
      case .boost:
        SoundEffectManager.shared.playSound(of: .boost)
        await statusDataController.toggleReblog(remoteStatus: viewModel.localStatusId)
      default:
        break
      }
    }
  }
}
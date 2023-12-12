
import SwiftUI
import UIKit

public extension StatusEditorViewModel {
  enum Mode {
    case replyTo(status: ModelsStatus)
    case new(visibility: Visibility)
    case edit(status: ModelsStatus)
    case quote(status: ModelsStatus)
    case mention(account: Account, visibility: Visibility)
    case shareExtension(items: [NSItemProvider])

    var isInShareExtension: Bool {
      switch self {
      case .shareExtension:
        true
      default:
        false
      }
    }

    var isEditing: Bool {
      switch self {
      case .edit:
        true
      default:
        false
      }
    }

    var replyToStatus: ModelsStatus? {
      switch self {
      case let .replyTo(status):
        status
      default:
        nil
      }
    }

    var title: LocalizedStringKey {
      switch self {
      case .new, .mention, .shareExtension:
        "status.editor.mode.new"
      case .edit:
        "status.editor.mode.edit"
      case let .replyTo(status):
        "status.editor.mode.reply-\(status.reblog?.account.displayNameWithoutEmojis ?? status.account.displayNameWithoutEmojis)"
      case let .quote(status):
        "status.editor.mode.quote-\(status.reblog?.account.displayNameWithoutEmojis ?? status.account.displayNameWithoutEmojis)"
      }
    }
  }
}

import SwiftUI

@MainActor
public extension View {
  func statusEditorToolbarItem(routerPath: RouterPath, visibility: Visibility) -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        routerPath.presentedSheet = .newStatusEditor(visibility: visibility)
        HapticManager.shared.fireHaptic(of: .buttonPress)
      } label: {
        Image(systemName: "square.and.pencil")
      }
    }
  }
}

@MainActor
public struct StatusEditorToolbarItem: ToolbarContent {
  @Environment(RouterPath.self) private var routerPath

  let visibility: Visibility

  public init(visibility: Visibility) {
    self.visibility = visibility
  }

  public var body: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      Button {
        Task { @MainActor in
          routerPath.presentedSheet = .newStatusEditor(visibility: visibility)
          HapticManager.shared.fireHaptic(of: .buttonPress)
        }
      } label: {
        Image(systemName: "square.and.pencil")
      }
    }
  }
}

@MainActor
public struct SecondaryColumnToolbarItem: ToolbarContent {
  @Environment(\.isSecondaryColumn) private var isSecondaryColumn
  @Environment(UserPreferences.self) private var preferences

  public init() {}

  public var body: some ToolbarContent {
    ToolbarItem(placement: isSecondaryColumn ? .navigationBarLeading : .navigationBarTrailing) {
      Button {
        withAnimation {
          preferences.showiPadSecondaryColumn.toggle()
        }
      } label: {
        Image(systemName: "sidebar.right")
      }
    }
  }
}

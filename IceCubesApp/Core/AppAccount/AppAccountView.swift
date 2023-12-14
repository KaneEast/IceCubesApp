import SwiftUI

@MainActor
public struct AppAccountView: View {
  @Environment(Theme.self) private var theme
  @Environment(RouterPath.self) private var routerPath
  @Environment(AppAccountsManager.self) private var appAccounts
  @Environment(UserPreferences.self) private var preferences
  
  @State var viewModel: AppAccountViewModel
  
  public init(viewModel: AppAccountViewModel) {
    self.viewModel = viewModel
  }
  
  public var body: some View {
    compactView
      .onAppear {
        Task {
          await viewModel.fetchAccount()
        }
      }
  }
  
  @ViewBuilder
  private var compactView: some View {
    HStack {
      if let account = viewModel.account {
        AvatarView(url: account.avatar)
      } else {
        ProgressView()
      }
    }
  }
}

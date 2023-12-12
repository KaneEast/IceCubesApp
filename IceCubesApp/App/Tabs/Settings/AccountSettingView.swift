





import SwiftUI

struct AccountSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  @Environment(CurrentAccount.self) private var currentAccount
  @Environment(CurrentInstance.self) private var currentInstance
  @Environment(Theme.self) private var theme
  @Environment(AppAccountsManager.self) private var appAccountsManager
  @Environment(Client.self) private var client

  @State private var isEditingAccount: Bool = false
  @State private var isEditingFilters: Bool = false
  @State private var cachedPostsCount: Int = 0

  let account: Account
  let appAccount: AppAccount

  var body: some View {
    Form {
      Section {
        Button {
          isEditingAccount = true
        } label: {
          Label("account.action.edit-info", systemImage: "pencil")
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        if currentInstance.isFiltersSupported {
          Button {
            isEditingFilters = true
          } label: {
            Label("account.action.edit-filters", systemImage: "line.3.horizontal.decrease.circle")
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      }
      .listRowBackground(theme.primaryBackgroundColor)

      Section {
        Button {
          openURL(URL(string: "https://\(client.server)/settings/profile")!)
        } label: {
          Text("account.action.more")
        }
      }
      .listRowBackground(theme.primaryBackgroundColor)

      Section {
        Button(role: .destructive) {
          if appAccount.oauthToken != nil {
            Task {
              //let client = Client(server: appAccount.server, oauthToken: token)
              appAccountsManager.delete(account: appAccount)
              dismiss()
            }
          }
        } label: {
          Text("account.action.logout")
            .frame(maxWidth: .infinity)
        }
      }
      .listRowBackground(theme.primaryBackgroundColor)
    }
    .sheet(isPresented: $isEditingAccount, content: {
      EditAccountView()
    })
    .sheet(isPresented: $isEditingFilters, content: {
      FiltersListView()
    })
    .toolbar {
      ToolbarItem(placement: .principal) {
        HStack {
          AvatarView(url: account.avatar, size: .embed)
          Text(account.safeDisplayName)
            .font(.headline)
        }
      }
    }
    .navigationTitle(account.safeDisplayName)
    .scrollContentBackground(.hidden)
    .background(theme.secondaryBackgroundColor)
  }
}

import Combine


import Observation
import SwiftUI

@MainActor
@Observable public class ListEditViewModel {
  let list: ModelsList

  var client: Client?

  var isLoadingAccounts: Bool = true
  var accounts: [Account] = []

  init(list: ModelsList) {
    self.list = list
  }

  func fetchAccounts() async {
    guard let client else { return }
    isLoadingAccounts = true
    do {
      accounts = try await client.get(endpoint: Lists.accounts(listId: list.id))
      isLoadingAccounts = false
    } catch {
      isLoadingAccounts = false
    }
  }

  func delete(account: Account) async {
    guard let client else { return }
    do {
      let response = try await client.delete(endpoint: Lists.updateAccounts(listId: list.id, accounts: [account.id]))
      if response?.statusCode == 200 {
        accounts.removeAll(where: { $0.id == account.id })
      }
    } catch {}
  }
}

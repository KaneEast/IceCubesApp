



import SwiftUI

@MainActor
public struct ListAddAccountView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(Client.self) private var client
  @Environment(Theme.self) private var theme
  @Environment(CurrentAccount.self) private var currentAccount
  @State private var viewModel: ListAddAccountViewModel

  @State private var isCreateListAlertPresented: Bool = false
  @State private var createListTitle: String = ""

  public init(account: Account) {
    _viewModel = .init(initialValue: .init(account: account))
  }

  public var body: some View {
    NavigationStack {
      List {
        ForEach(currentAccount.sortedLists) { list in
          HStack {
            Toggle(list.title, isOn: .init(get: {
              viewModel.inLists.contains(where: { $0.id == list.id })
            }, set: { value in
              Task {
                if value {
                  await viewModel.addToList(list: list)
                } else {
                  await viewModel.removeFromList(list: list)
                }
              }
            }))
            .disabled(viewModel.isLoadingInfo)
            Spacer()
          }
          .listRowBackground(Color.white)
        }
        Button("lists.create") {
          isCreateListAlertPresented = true
        }
        .listRowBackground(Color.white)
      }
      .scrollContentBackground(.hidden)
      .background(Color.white.opacity(0.9))
      .navigationTitle("lists.add-remove-\(viewModel.account.safeDisplayName)")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button("action.done") {
            dismiss()
          }
        }
      }
      .alert("lists.create", isPresented: $isCreateListAlertPresented) {
        TextField("lists.name", text: $createListTitle)
        Button("action.cancel") {
          isCreateListAlertPresented = false
          createListTitle = ""
        }
        Button("lists.create.confirm") {
          guard !createListTitle.isEmpty else { return }
          isCreateListAlertPresented = false
          Task {
            await currentAccount.createList(title: createListTitle)
            createListTitle = ""
          }
        }
      } message: {
        Text("lists.name.message")
      }
    }
    .task {
      viewModel.client = client
      await viewModel.fetchInfo()
    }
  }
}

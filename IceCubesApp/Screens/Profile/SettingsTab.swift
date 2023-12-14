import Foundation
import SwiftData
import SwiftUI

@MainActor
struct SettingsTabs: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
  
  @Environment(UserPreferences.self) private var preferences
  @Environment(Client.self) private var client
  @Environment(CurrentInstance.self) private var currentInstance
  @Environment(AppAccountsManager.self) private var appAccountsManager
  @Environment(Theme.self) private var theme
  
  @State private var routerPath = RouterPath()
  @State private var addAccountSheetPresented = false
  @State private var isEditingAccount = false
  @State private var cachedRemoved = false
  
  @Binding var popToRootTab: Tab
  
  @Query(sort: \LocalTimeline.creationDate, order: .reverse) var localTimelines: [LocalTimeline]
  @Query(sort: \TagGroup.creationDate, order: .reverse) var tagGroups: [TagGroup]
  
  var body: some View {
    NavigationStack(path: $routerPath.path) {
      Form {
        appSection
        accountsSection
        generalSection
        otherSections
      }
      .navigationTitle(Text("settings.title"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button {
            dismiss()
          } label: {
            Text("action.done").bold()
          }
        }
      }
      .withAppRouter()
      .withSheetDestinations(sheetDestinations: $routerPath.presentedSheet)
    }
    .onAppear {
      routerPath.client = client
    }
    .task {
      if appAccountsManager.currentAccount.oauthToken != nil {
        await currentInstance.fetchCurrentInstance()
      }
    }
    .withSafariRouter()
    .environment(routerPath)
  }
  
  private var accountsSection: some View {
    Section("settings.section.accounts") {
      ForEach(appAccountsManager.availableAccounts) { account in
        HStack {
          if isEditingAccount {
            Button {
              Task {
                await logoutAccount(account: account)
              }
            } label: {
              Image(systemName: "trash")
                .renderingMode(.template)
                .tint(.red)
            }
          }
          AppAccountView(viewModel: .init(appAccount: account))
        }
      }
      .onDelete { indexSet in
        if let index = indexSet.first {
          let account = appAccountsManager.availableAccounts[index]
          Task {
            await logoutAccount(account: account)
          }
        }
      }
      if !appAccountsManager.availableAccounts.isEmpty {
        editAccountButton
      }
      addAccountButton
    }
    .listRowBackground(Color.white)
  }
  
  private func logoutAccount(account: AppAccount) async {
    appAccountsManager.delete(account: account)
  }
  
  @ViewBuilder
  private var generalSection: some View {
    Section("settings.section.general") {
      if let instanceData = currentInstance.instance {
        NavigationLink(destination: InstanceInfoView(instance: instanceData)) {
          Label("settings.general.instance", systemImage: "server.rack")
        }
      }
      NavigationLink(destination: DisplaySettingsView()) {
        Label("settings.general.display", systemImage: "paintpalette")
      }
      if HapticManager.shared.supportsHaptics {
        NavigationLink(destination: HapticSettingsView()) {
          Label("settings.general.haptic", systemImage: "waveform.path")
        }
      }
      NavigationLink(destination: remoteLocalTimelinesView) {
        Label("settings.general.remote-timelines", systemImage: "dot.radiowaves.right")
      }
      NavigationLink(destination: ContentSettingsView()) {
        Label("settings.general.content", systemImage: "rectangle.stack")
      }
      NavigationLink(destination: SwipeActionsSettingsView()) {
        Label("settings.general.swipeactions", systemImage: "hand.draw")
      }
      NavigationLink(destination: TranslationSettingsView()) {
        Label("settings.general.translate", systemImage: "captions.bubble")
      }
      Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
        Label("settings.system", systemImage: "gear")
      }
      .tint(theme.labelColor)
    }
    .listRowBackground(Color.white)
  }
  
  @ViewBuilder
  private var otherSections: some View {
    @Bindable var preferences = preferences
    Section("settings.section.other") {
      if !ProcessInfo.processInfo.isiOSAppOnMac {
        Picker(selection: $preferences.preferredBrowser) {
          ForEach(PreferredBrowser.allCases, id: \.rawValue) { browser in
            switch browser {
            case .inAppSafari:
              Text("settings.general.browser.in-app").tag(browser)
            case .safari:
              Text("settings.general.browser.system").tag(browser)
            }
          }
        } label: {
          Label("settings.general.browser", systemImage: "network")
        }
        Toggle(isOn: $preferences.inAppBrowserReaderView) {
          Label("settings.general.browser.in-app.readerview", systemImage: "doc.plaintext")
        }
        .disabled(preferences.preferredBrowser != PreferredBrowser.inAppSafari)
      }
      Toggle(isOn: $preferences.isOpenAIEnabled) {
        Label("settings.other.hide-openai", systemImage: "faxmachine")
      }
      Toggle(isOn: $preferences.isSocialKeyboardEnabled) {
        Label("settings.other.social-keyboard", systemImage: "keyboard")
      }
      Toggle(isOn: $preferences.soundEffectEnabled) {
        Label("settings.other.sound-effect", systemImage: "hifispeaker")
      }
    }
    .listRowBackground(Color.white)
  }
  
  private var appSection: some View {
    Section {
      NavigationLink(destination: AboutView()) {
        Label("settings.app.about", systemImage: "info.circle")
      }
    } header: {
      Text("settings.section.app")
    } footer: {
      if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        Text("settings.section.app.footer \(appVersion)").frame(maxWidth: .infinity, alignment: .center)
      }
    }
    .listRowBackground(Color.white)
  }
  
  private var addAccountButton: some View {
    Button {
      addAccountSheetPresented.toggle()
    } label: {
      Text("settings.account.add")
    }
    .sheet(isPresented: $addAccountSheetPresented) {
      AddAccountView()
    }
  }
  
  private var editAccountButton: some View {
    Button(role: isEditingAccount ? .none : .destructive) {
      withAnimation {
        isEditingAccount.toggle()
      }
    } label: {
      if isEditingAccount {
        Text("action.done")
      } else {
        Text("account.action.logout")
      }
    }
  }
  
  private var remoteLocalTimelinesView: some View {
    Form {
      ForEach(localTimelines) { timeline in
        Text(timeline.instance)
      }.onDelete { indexes in
        if let index = indexes.first {
          context.delete(localTimelines[index])
        }
      }
      .listRowBackground(Color.white)
      Button {
        routerPath.presentedSheet = .addRemoteLocalTimeline
      } label: {
        Label("settings.timeline.add", systemImage: "badge.plus.radiowaves.right")
      }
      .listRowBackground(Color.white)
    }
    .navigationTitle("settings.general.remote-timelines")
    .scrollContentBackground(.hidden)
    .toolbar {
      EditButton()
    }
  }
}

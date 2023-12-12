

import AVFoundation


import KeychainSwift


import SwiftUI

@main
struct IceCubesApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
  
  @Environment(\.scenePhase) private var scenePhase
  
  @State private var appAccountsManager = AppAccountsManager.shared
  @State private var currentInstance = CurrentInstance.shared
  @State private var currentAccount = CurrentAccount.shared
  @State private var userPreferences = UserPreferences.shared
  @State private var watcher = StreamWatcher()
  @State private var quickLook = QuickLook()
  @State private var theme = Theme.shared
  @State private var sidebarRouterPath = RouterPath()
  
  @State private var selectedTab: Tab = .timeline
  @State private var popToRootTab: Tab = .other
  @State private var sideBarLoadedTabs: Set<Tab> = Set()
  @State private var isSupporter: Bool = false
  
  private var availableTabs: [Tab] {
    appAccountsManager.currentClient.isAuth ? Tab.loggedInTabs() : Tab.loggedOutTab()
  }
  
  var body: some Scene {
    WindowGroup {
      appView
        .applyTheme(theme)
        .onAppear {
          setNewClientsInEnv(client: appAccountsManager.currentClient)
        }
        .environment(appAccountsManager)
        .environment(appAccountsManager.currentClient)
        .environment(quickLook)
        .environment(currentAccount)
        .environment(currentInstance)
        .environment(userPreferences)
        .environment(theme)
        .environment(watcher)
        .environment(\.isSupporter, isSupporter)
        .sheet(item: $quickLook.selectedMediaAttachment) { selectedMediaAttachment in
          MediaUIView(selectedAttachment: selectedMediaAttachment,
                      attachments: quickLook.mediaAttachments)
          .presentationBackground(.ultraThinMaterial)
          .presentationCornerRadius(16)
          .environment(userPreferences)
          .environment(theme)
        }
        .fullScreenCover(item: $quickLook.url, content: { url in
          QuickLookPreview(selectedURL: url, urls: quickLook.urls)
            .edgesIgnoringSafeArea(.bottom)
            .background(TransparentBackground())
        })
        .withModelContainer()
    }
    .commands {
      appMenu
    }
    .onChange(of: scenePhase) { _, newValue in
      handleScenePhase(scenePhase: newValue)
    }
    .onChange(of: appAccountsManager.currentClient) { _, newValue in
      setNewClientsInEnv(client: newValue)
      if newValue.isAuth {
        watcher.watch(streams: [.user, .direct])
      }
    }
  }
  
  @ViewBuilder
  private var appView: some View {
    if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac {
      sidebarView
    } else {
      tabBarView
    }
  }
  
  private var sidebarView: some View {
    SideBarView(selectedTab: $selectedTab,
                popToRootTab: $popToRootTab,
                tabs: availableTabs)
    {
      HStack(spacing: 0) {
        ZStack {
          if selectedTab == .profile {
            ProfileTab(popToRootTab: $popToRootTab)
          }
          ForEach(availableTabs) { tab in
            if tab == selectedTab || sideBarLoadedTabs.contains(tab) {
              tab
                .makeContentView(popToRootTab: $popToRootTab)
                .opacity(tab == selectedTab ? 1 : 0)
                .transition(.opacity)
                .id("\(tab)\(appAccountsManager.currentAccount.id)")
                .onAppear {
                  sideBarLoadedTabs.insert(tab)
                }
            } else {
              EmptyView()
            }
          }
        }
        if appAccountsManager.currentClient.isAuth,
           userPreferences.showiPadSecondaryColumn
        {
          Divider().edgesIgnoringSafeArea(.all)
        }
      }
    }.onChange(of: $appAccountsManager.currentAccount.id) {
      sideBarLoadedTabs.removeAll()
    }
    .environment(sidebarRouterPath)
  }
  
  
  private var tabBarView: some View {
    TabView {
      ForEach(availableTabs) { tab in
        tab.makeContentView(popToRootTab: $popToRootTab)
          .tabItem {
            if userPreferences.showiPhoneTabLabel {
              tab.label
            } else {
              Image(systemName: tab.iconName)
            }
          }
          .tag(tab)
          .toolbarBackground(theme.primaryBackgroundColor.opacity(0.50), for: .tabBar)
      }
    }
    .id(appAccountsManager.currentClient.id)
  }
  
  private func setNewClientsInEnv(client: Client) {
    currentAccount.setClient(client: client)
    currentInstance.setClient(client: client)
    userPreferences.setClient(client: client)
    Task {
      await currentInstance.fetchCurrentInstance()
      watcher.setClient(client: client, instanceStreamingURL: currentInstance.instance?.urls?.streamingApi)
      watcher.watch(streams: [.user, .direct])
    }
  }
  
  private func handleScenePhase(scenePhase: ScenePhase) {
    switch scenePhase {
    case .background:
      watcher.stopWatching()
    case .active:
      watcher.watch(streams: [.user, .direct])
      UNUserNotificationCenter.current().setBadgeCount(0)
      userPreferences.reloadNotificationsCount(tokens: appAccountsManager.availableAccounts.compactMap(\.oauthToken))
      Task {
        await userPreferences.refreshServerPreferences()
      }
    default:
      break
    }
  }
  
  @CommandsBuilder
  private var appMenu: some Commands {
    CommandGroup(replacing: .newItem) {
      Button("menu.new-post") {
        sidebarRouterPath.presentedSheet = .newStatusEditor(visibility: userPreferences.postVisibility)
      }
    }
    CommandGroup(replacing: .textFormatting) {
      Menu("menu.font") {
        Button("menu.font.bigger") {
          if theme.fontSizeScale < 1.5 {
            theme.fontSizeScale += 0.1
          }
        }
        Button("menu.font.smaller") {
          if theme.fontSizeScale > 0.5 {
            theme.fontSizeScale -= 0.1
          }
        }
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_: UIApplication,
                   didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
  {
    try? AVAudioSession.sharedInstance().setCategory(.ambient)
    return true
  }
  
  func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    if connectingSceneSession.role == .windowApplication {
      configuration.delegateClass = SceneDelegate.self
    }
    return configuration
  }
}

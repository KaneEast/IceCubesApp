


import Foundation

import SwiftUI

@MainActor
enum Tab: Int, Identifiable, Hashable {
  case timeline, explore, settings
  case profile, other

  nonisolated var id: Int {
    rawValue
  }

  static func loggedOutTab() -> [Tab] {
    [.timeline, .settings]
  }

  static func loggedInTabs() -> [Tab] {
      [.timeline, .explore, .profile]
  }

  @ViewBuilder
  func makeContentView(popToRootTab: Binding<Tab>) -> some View {
    switch self {
    case .timeline:
      TimelineTab(popToRootTab: popToRootTab)
    case .explore:
      ExploreTab(popToRootTab: popToRootTab)
    case .settings:
      SettingsTabs(popToRootTab: popToRootTab)
    case .profile:
      ProfileTab(popToRootTab: popToRootTab)
    case .other:
      EmptyView()
    }
  }

  @ViewBuilder
  var label: some View {
    switch self {
    case .timeline:
      Label("tab.timeline", systemImage: iconName)
    case .explore:
      Label("tab.explore", systemImage: iconName)
    case .settings:
      Label("tab.settings", systemImage: iconName)
    case .profile:
      Label("tab.profile", systemImage: iconName)
    case .other:
      EmptyView()
    }
  }

  var iconName: String {
    switch self {
    case .timeline:
      "rectangle.stack"
    case .explore:
      "magnifyingglass"
    case .settings:
      "gear"
    case .profile:
      "person.crop.circle"
    case .other:
      ""
    }
  }
}



import SwiftUI

struct InstanceInfoView: View {
  @Environment(Theme.self) private var theme

  let instance: Instance

  var body: some View {
    Form {
      InstanceInfoSection(instance: instance)
    }
    .navigationTitle("instance.info.navigation-title")
    .scrollContentBackground(.hidden)
    .background(Color.white.opacity(0.9))
  }
}

public struct InstanceInfoSection: View {
  @Environment(Theme.self) private var theme

  let instance: Instance

  public var body: some View {
    Section("instance.info.section.info") {
      LabeledContent("instance.info.name", value: instance.title)
      Text(instance.shortDescription)
      LabeledContent("instance.info.email", value: instance.email)
      LabeledContent("instance.info.version") {
        Text(instance.version).monospaced()
      }
      LabeledContent("instance.info.users", value: format(instance.stats.userCount))
      LabeledContent("instance.info.posts", value: format(instance.stats.statusCount))
      LabeledContent("instance.info.domains", value: format(instance.stats.domainCount))
    }
    .listRowBackground(Color.white)

    if let rules = instance.rules {
      Section("instance.info.section.rules") {
        ForEach(rules) { rule in
          Text(rule.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
      }
      .listRowBackground(Color.white)
    }
  }

  private func format(_ int: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: int))!
  }
}

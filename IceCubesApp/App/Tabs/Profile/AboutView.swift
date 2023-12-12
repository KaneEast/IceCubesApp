import SwiftUI

@MainActor
struct AboutView: View {
  @Environment(RouterPath.self) private var routerPath
  @Environment(Theme.self) private var theme

  let versionNumber: String

  init() {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      versionNumber = version + " "
    } else {
      versionNumber = ""
    }
  }

  var body: some View {
    List {
      Section {
        Text("""
        • [EmojiText](https://github.com/divadretlaw/EmojiText)

        • [HTML2Markdown](https://gitlab.com/mflint/HTML2Markdown)

        • [KeychainSwift](https://github.com/evgenyneu/keychain-swift)

        • [SwiftSoup](https://github.com/scinfu/SwiftSoup.git)

        • [SwiftUI-Introspect](https://github.com/siteline/SwiftUI-Introspect)

        • [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols)
        """)
        .multilineTextAlignment(.leading)
        .font(.scaledSubheadline)
        .foregroundColor(.gray)
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle("Libraries")
    .navigationBarTitleDisplayMode(.large)
    .environment(\.openURL, OpenURLAction { url in
      routerPath.handle(url: url)
    })
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
      .environment(Theme.shared)
  }
}

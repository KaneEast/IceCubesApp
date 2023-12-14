import Foundation
import Observation
import SwiftUI

@MainActor
@Observable class PendingStatusesObserver {
  var pendingStatusesCount: Int = 0

  var disableUpdate: Bool = false
  var scrollToIndex: ((Int) -> Void)?

  var pendingStatuses: [String] = [] {
    didSet {
      pendingStatusesCount = pendingStatuses.count
    }
  }

  func removeStatus(status: ModelsStatus) {
    if !disableUpdate, let index = pendingStatuses.firstIndex(of: status.id) {
      pendingStatuses.removeSubrange(index ... (pendingStatuses.count - 1))
      HapticManager.shared.fireHaptic(of: .timeline)
    }
  }

  init() {}
}

struct PendingStatusesObserverView: View {
  @State var observer: PendingStatusesObserver
  @Environment(UserPreferences.self) private var preferences
  var body: some View {
    if observer.pendingStatusesCount > 0 {
      HStack(spacing: 6) {
        Spacer()
        Button {
          observer.scrollToIndex?(observer.pendingStatusesCount)
        } label: {
          Text("\(observer.pendingStatusesCount)")
            // Accessibility: this results in a frame with a size of at least 44x44 at regular font size
            .frame(minWidth: 30, minHeight: 30)
        }
        .buttonStyle(.bordered)
        .background(.thinMaterial)
        .cornerRadius(8)
      }
      .padding(12)
      .frame(maxHeight: .infinity, alignment: preferences.pendingShownAtBottom ? .bottom : .top)
    }
  }
}
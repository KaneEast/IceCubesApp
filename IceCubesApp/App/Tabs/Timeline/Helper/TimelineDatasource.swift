import Foundation


actor TimelineDatasource {
  private var statuses: [ModelsStatus] = []

  var isEmpty: Bool {
    statuses.isEmpty
  }

  func get() -> [ModelsStatus] {
    statuses.filter { $0.filtered?.first?.filter.filterAction != .hide }
  }

  func reset() {
    statuses = []
  }

  func indexOf(statusId: String) -> Int? {
    statuses.firstIndex(where: { $0.id == statusId })
  }

  func contains(statusId: String) -> Bool {
    statuses.contains(where: { $0.id == statusId })
  }

  func set(_ statuses: [ModelsStatus]) {
    self.statuses = statuses
  }

  func append(_ status: ModelsStatus) {
    statuses.append(status)
  }

  func append(contentOf: [ModelsStatus]) {
    statuses.append(contentsOf: contentOf)
  }

  func insert(_ status: ModelsStatus, at: Int) {
    statuses.insert(status, at: at)
  }

  func insert(contentOf: [ModelsStatus], at: Int) {
    statuses.insert(contentsOf: contentOf, at: at)
  }

  func replace(_ status: ModelsStatus, at: Int) {
    statuses[at] = status
  }

  func remove(_ statusId: String) {
    statuses.removeAll(where: { $0.id == statusId })
  }
}

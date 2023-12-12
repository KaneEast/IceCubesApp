import Combine

import Observation
import SwiftUI

public enum StatusesState {
  public enum PagingState {
    case hasNextPage, loadingNextPage, none
  }

  case loading
  case display(statuses: [ModelsStatus], nextPageState: StatusesState.PagingState)
  case error(error: Error)
}

@MainActor
public protocol StatusesFetcher {
  var statusesState: StatusesState { get }
  func fetchNewestStatuses() async
  func fetchNextPage() async
  func statusDidAppear(status: ModelsStatus)
  func statusDidDisappear(status: ModelsStatus)
}

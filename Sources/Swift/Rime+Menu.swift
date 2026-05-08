//
//  Rime+Menu.swift
//  LibrimeKit
//
//  Candidate menu — fetch, paginate, select, highlight.
//

import Foundation
@_exported import RimeKitObjC

public extension Rime {

  // MARK: - Fetch

  /// All candidates currently visible to librime (typically a
  /// single page; for paginated reads use
  /// `candidateListWithIndex(index:andCount:)`).
  func candidateList() -> [CandidateWord] {
    let candidates = rimeAPI.getCandidateList(session)
    if candidates != nil {
      return candidates!.map {
        CandidateWord(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }

  /// Raw `LRKCandidate` slice — same data as `candidateList()`
  /// but without the value-type conversion. Use when bridging
  /// back into ObjC code or when you need the raw pointer
  /// identity.
  func getCandidate(index: Int, count: Int) -> [LRKCandidate] {
    rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count), andSession: session) ?? []
  }

  /// Paginated candidate fetch.
  ///
  /// - Parameters:
  ///   - index: 1-based candidate index (page 1 = 1, page 2 = `count + 1`, ...).
  ///   - count: page size.
  func candidateListWithIndex(index: Int, andCount count: Int) -> [CandidateWord] {
    let candidates = rimeAPI.getCandidateWith(
      Int32(index), andCount: Int32(count), andSession: session
    )
    if candidates != nil {
      return candidates!.map {
        CandidateWord(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }

  // MARK: - Select

  func selectCandidate(index: Int) -> Bool {
    return rimeAPI.selectCandidate(session, andIndex: Int32(index))
  }

  /// Select a candidate from the current page by its page-local
  /// index. Modern replacement for `selectCandidate(index:)` whose
  /// underlying `rime_api->select_candidate` is deprecated and has
  /// been observed to silently no-op on rime_ice and other schemas.
  func selectCandidateOnCurrentPage(index: Int) -> Bool {
    return rimeAPI.selectCandidate(onCurrentPage: session, andIndex: Int32(index))
  }

  /// Highlight (without committing) a candidate by its page-local
  /// index. Added in librime 1.16.x.
  func highlightCandidateOnCurrentPage(index: Int) -> Bool {
    return rimeAPI.highlightCandidate(onCurrentPage: session, andIndex: Int32(index))
  }

  // MARK: - Page navigation

  /// Modern page-navigation API. Pass `backward = false` to advance
  /// to the next page, `true` to retreat. Replaces the old "send
  /// XK_Page_Down/XK_Page_Up keycode" trick which relied on schema
  /// keybindings that some schemas (rime_ice) don't have.
  func changePage(backward: Bool) -> Bool {
    return rimeAPI.changePage(session, backward: backward)
  }
}

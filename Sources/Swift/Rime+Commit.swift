//
//  Rime+Commit.swift
//  LibrimeKit
//
//  Commit the in-progress composition.
//

import Foundation
@_exported import RimeKitObjC

public extension Rime {
  /// Commit whatever Rime is currently composing — equivalent to
  /// the user pressing Enter while the candidate menu is open.
  /// Useful as a one-shot "force commit" path when the candidate-
  /// selection APIs aren't doing what you need.
  func commitComposition() -> Bool {
    return rimeAPI.commitComposition(session)
  }

  /// Drain any text librime is waiting to commit. Returns the
  /// committed text (may be empty). Call after `inputKey(_:)` /
  /// `inputKeyCode(_:)` to pick up auto-commits.
  func getCommitText() -> String {
    return rimeAPI.getCommit(session)!
  }
}

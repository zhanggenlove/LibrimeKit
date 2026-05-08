//
//  CandidateWord.swift
//  LibrimeKit
//
//  Plain mirror of librime's `LRKCandidate` for Swift consumers.
//

import Foundation

/// One candidate word produced by librime.
///
/// `text` is the glyph(s) that will be committed; `comment` is the
/// schema-supplied annotation (typically pinyin or a code hint).
/// Distinct from `CandidateSuggestion` — that one carries UI state.
public struct CandidateWord {
  public var text: String
  public var comment: String

  public init(text: String, comment: String) {
    self.text = text
    self.comment = comment
  }
}

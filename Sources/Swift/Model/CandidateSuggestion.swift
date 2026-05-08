//
//  CandidateSuggestion.swift
//  LibrimeKit
//
//  UI-facing model for one row in the candidate bar.
//

import Foundation

/// One entry shown in the keyboard's candidate bar.
///
/// Distinct from `CandidateWord` (which mirrors librime's raw output)
/// — this carries display-time metadata such as a UI title that may
/// differ from the inserted text, autocomplete styling flags, and an
/// `additionalInfo` bag for engine-specific extras.
public struct CandidateSuggestion: Identifiable, Equatable, Hashable {
  public var id = UUID()

  /// Index of the candidate within the current page.
  public var index: Int

  /// Text to send to `documentProxy` when the user picks this row.
  public var text: String

  /// Text rendered in the candidate cell. Often equal to `text`,
  /// but engines may show e.g. a glyph hint differently from what
  /// they actually insert.
  public var title: String

  /// Optional secondary line (comment / pinyin annotation).
  public var subtitle: String?

  /// Marks this row as an autocomplete suggestion. Mirrors the
  /// iOS-system-keyboard convention of rendering autocomplete
  /// suggestions inside a white rounded chip.
  public var isAutocomplete: Bool

  /// Marks this row as an "unknown" / out-of-vocabulary suggestion.
  /// iOS renders these wrapped in quotation marks.
  public var isUnknown: Bool

  /// Free-form bag for engine-specific data the UI layer may want
  /// to surface (debugging info, schema-specific flags, etc.).
  public var additionalInfo: [String: Any]

  public init(
    index: Int,
    text: String,
    title: String? = nil,
    isAutocomplete: Bool = false,
    isUnknown: Bool = false,
    subtitle: String? = nil,
    additionalInfo: [String: Any] = [:]
  ) {
    self.index = index
    self.text = text
    self.title = title ?? text
    self.isAutocomplete = isAutocomplete
    self.isUnknown = isUnknown
    self.subtitle = subtitle
    self.additionalInfo = additionalInfo
  }
}

public extension CandidateSuggestion {
  static func == (lhs: CandidateSuggestion, rhs: CandidateSuggestion) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

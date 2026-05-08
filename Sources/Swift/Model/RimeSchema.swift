//
//  RimeSchema.swift
//  LibrimeKit
//
//  Swift mirror of `LRKSchema` — one entry from rime's schema list.
//

import Foundation

/// A Rime input schema (e.g. `pinyin_simp`, `wubi86`, `rime_ice`).
///
/// `schemaId` is the stable filename token used by librime; `schemaName`
/// is the human-readable label shown in pickers. Two schemas are
/// considered equal iff their `schemaId` matches — names can drift
/// across config edits but the id is what librime keys off.
public struct RimeSchema: Identifiable, Equatable, Hashable, Comparable, Codable {
  public var id: String
  public var schemaId: String
  public var schemaName: String

  public init(schemaId: String, schemaName: String) {
    self.id = schemaId
    self.schemaId = schemaId
    self.schemaName = schemaName
  }
}

public extension RimeSchema {
  static func < (lhs: RimeSchema, rhs: RimeSchema) -> Bool {
    lhs.schemaId <= rhs.schemaId
  }

  static func == (lhs: RimeSchema, rhs: RimeSchema) -> Bool {
    return lhs.schemaId == rhs.schemaId
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(schemaId)
  }
}

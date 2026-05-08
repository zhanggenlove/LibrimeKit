//
//  LRKStatus+.swift
//  LibrimeKit
//
//  Bridge from the ObjC `LRKStatus` to the Swift `RimeSchema` value.
//

import Foundation
@_exported import RimeKitObjC

extension LRKStatus {
  /// Build a `RimeSchema` from this status snapshot. Defaults to
  /// empty strings when librime returns nil (`schemaId` /
  /// `schemaName` are nullable in the ObjC bridge).
  func currentSchema() -> RimeSchema {
    RimeSchema(
      schemaId: self.schemaId == nil ? "" : self.schemaId,
      schemaName: self.schemaName == nil ? "" : self.schemaName
    )
  }
}

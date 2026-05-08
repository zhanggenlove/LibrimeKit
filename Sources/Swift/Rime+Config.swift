//
//  Rime+Config.swift
//  LibrimeKit
//
//  Status / context observers, mode toggles, schema management,
//  and config-file readers. Everything that reads or writes Rime
//  configuration state lives here.
//

import Foundation
@_exported import RimeKitObjC

// MARK: - Status & Context

public extension Rime {
  /// Snapshot of mode flags + current schema. Cheap to call —
  /// no allocation beyond the returned object.
  func status() -> LRKStatus {
    return rimeAPI.getStatus(session)
  }

  /// Snapshot of composition + menu page metadata. Useful for
  /// driving a custom candidate UI that mirrors librime's own
  /// pagination state.
  func context() -> LRKContext {
    return rimeAPI.getContext(session)
  }
}

// MARK: - Mode toggles

public extension Rime {
  func isAsciiMode() -> Bool {
    return rimeAPI.getOption(session, andOption: Self.asciiModeKey)
  }

  func asciiMode(_ value: Bool) -> Bool {
    return rimeAPI.setOption(session, andOption: Self.asciiModeKey, andValue: value)
  }

  func simplifiedChineseMode(key: String) -> Bool {
    return rimeAPI.getOption(session, andOption: key)
  }

  func setSimplifiedChineseMode(key: String, value: Bool) -> Bool {
    currentSimplifiedModeKey = key
    currentSimplifiedModeValue = value
    return rimeAPI.setOption(session, andOption: key, andValue: value)
  }
}

// MARK: - Schemas

public extension Rime {
  func openSchema(schema: String) -> LRKConfig {
    rimeAPI.openSchema(schema)
  }

  func getSchemas() -> [RimeSchema] {
    return rimeAPI.schemaList().map {
      RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName)
    }
  }

  func currentSchema() -> RimeSchema? {
    let status = rimeAPI.getStatus(session)!
    return RimeSchema(schemaId: status.schemaId, schemaName: status.schemaName)
  }

  func setSchema(_ schemaId: String) -> Bool {
    createSession()
    return rimeAPI.selectSchema(session, andSchemaId: schemaId)
  }

  /// NOTE: requires `default.custom.yaml` to exist in the user
  /// data directory; otherwise rime returns an empty list.
  func getAvailableRimeSchemas() -> [RimeSchema] {
    rimeAPI.getAvailableRimeSchemaList()
      .map { RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }

  func getSelectedRimeSchema() -> [RimeSchema] {
    rimeAPI.getSelectedRimeSchemaList()
      .map { RimeSchema(schemaId: $0.schemaId, schemaName: $0.schemaName) }
  }
}

// MARK: - Config files

public extension Rime {
  func getHotkeys() -> String {
    rimeAPI.getHotkeys()
  }

  /// Read a string value from a user-config yaml file. Returns
  /// `nil` if the file can't be opened. Closes the config handle
  /// before returning.
  func getConfigFileValue(configFileName: String, key: String) -> String? {
    guard let config = rimeAPI.openUserConfig(configFileName) else { return nil }
    let value = config.getString(key)
    config.close()
    return value
  }
}

//
//  Rime+Notifications.swift
//  LibrimeKit
//
//  Deploy / schema-change notification surface. Callback storage
//  lives on `Rime` itself; the setters and the protocol-conformance
//  hooks live here.
//

import Foundation
@_exported import RimeKitObjC

// MARK: - Callback setters

public extension Rime {
  func setDeployStartCallback(callback: @escaping () -> Void) {
    deployStartCallback = callback
  }

  func setDeploySuccessCallback(callback: @escaping () -> Void) {
    deploySuccessCallback = callback
  }

  func setDeployFailureCallback(callback: @escaping () -> Void) {
    deployFailureCallback = callback
  }

  func setChangeModeCallback(callback: @escaping (String) -> Void) {
    changeModeCallback = callback
  }

  func setLoadingSchemaCallback(callback: @escaping (String) -> Void) {
    loadingSchemaCallback = callback
  }
}

// MARK: - LRKNotificationDelegate

public extension Rime {
  func onDeployStart() {
    logger.info("RimeNotification: onDeployStart")
    deployStartCallback?()
  }

  func onDeploySuccess() {
    logger.info("RimeNotification: onDeploySuccess")
    deploySuccessCallback?()
  }

  func onDeployFailure() {
    logger.info("RimeNotification: onDeployFailure")
    deployFailureCallback?()
  }

  func onChangeMode(_ mode: String) {
    logger.info("RimeNotification: onChangeMode, mode: \(mode)")
    changeModeCallback?(mode)
  }

  func onLoadingSchema(_ schema: String) {
    logger.info("RimeNotification: onLoadingSchema, schema: \(schema)")
    loadingSchemaCallback?(schema)
  }
}

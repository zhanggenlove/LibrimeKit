//
//  Rime+Lifecycle.swift
//  LibrimeKit
//
//  Process-level setup, deploy, and shutdown.
//

import Foundation
@_exported import RimeKitObjC

public extension Rime {

  // MARK: - Setup

  private func setNotificationDelegate(_ delegate: LRKNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }

  func setupRime(sharedSupportDir: String, userDataDir: String) {
    setupRime(Self.createTraits(sharedSupportDir: sharedSupportDir, userDataDir: userDataDir))
  }

  /// One-time global init. Safe to call multiple times in a
  /// single process — only the first call hits `RimeSetup`. The
  /// lock + `isFirstRun` flag exist because `InitGoogleLogging`
  /// (called transitively by `RimeSetup`) crashes on a second
  /// invocation.
  func setupRime(_ traits: LRKTraits) {
    setupLock.lock()
    defer { setupLock.unlock() }
    if isFirstRun {
      setNotificationDelegate(self)
      rimeAPI.setup(traits)
      isFirstRun = false
    }
  }

  // MARK: - Initialize / Start

  func initialize(_ traits: LRKTraits? = nil) {
    rimeAPI.initialize(traits)
  }

  /// Convenience wrapper: setup (if traits given) → initialize →
  /// optional maintenance pass.
  ///
  /// - Parameters:
  ///   - traits: pass non-nil only on the very first start. Re-
  ///     starts within the same process should pass `nil`.
  ///   - maintenance: when `true`, runs a maintenance pass which
  ///     compiles any updated schema yaml.
  ///   - fullCheck: forces re-compile even if file timestamps
  ///     suggest no changes. Required after `selectRimeSchemas`.
  func start(_ traits: LRKTraits? = nil, maintenance: Bool = false, fullCheck: Bool = false) {
    if let traits = traits {
      setupRime(traits)
    }

    self.traits = traits

    initialize(traits)

    if maintenance {
      rimeAPI.startMaintenance(fullCheck)
    }
  }

  // MARK: - Deploy

  func deploy(_ traits: LRKTraits? = nil) -> Bool {
    rimeAPI.deployerInitialize(traits)
    return rimeAPI.deploy()
  }

  // MARK: - Shutdown

  /// Destroys the session and tears down librime. After this
  /// call, `setupRime(_:)` would still be a no-op due to the
  /// first-run guard — librime as a process-global singleton
  /// can't be re-initialized within the same process.
  func shutdown() {
    rimeAPI.destroySession(session)
    session = 0
    rimeAPI.finalize()
  }
}

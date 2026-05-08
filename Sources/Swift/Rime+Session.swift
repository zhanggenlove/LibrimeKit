//
//  Rime+Session.swift
//  LibrimeKit
//
//  Session lifecycle (create / destroy / reset).
//

import Foundation
@_exported import RimeKitObjC

public extension Rime {
  func isRunning() -> Bool {
    return session != 0
  }

  func getSession() -> RimeSessionId {
    return session
  }

  /// Open a session if none is open. Idempotent.
  func createSession() {
    if !isRunning() {
      session = rimeAPI.createSession()
    }
  }

  /// Destroy the current session and start a fresh one. Useful
  /// for clearing session-local state (e.g. mid-composition
  /// preedit) without going through full shutdown/setup.
  func restSession() {
    rimeAPI.destroySession(session)
    session = rimeAPI.createSession()
  }
}

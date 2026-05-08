//
//  Rime.swift
//  LibrimeKit
//
//  Swift facade over the librime ObjC binding (`LRKAPI`).
//  Owns a process-singleton session and routes deploy /
//  schema-loading notifications back to user-supplied callbacks.
//
//  Implementation is split across `Rime+*.swift` extension files
//  by concern (Lifecycle / Session / Input / Menu / Commit /
//  Config / Notifications). Stored state on this class is
//  declared `internal` (no access modifier) so those extensions
//  can read/mutate it.
//

import Foundation
import os
@_exported import RimeKitObjC

/// High-level wrapper around librime.
///
/// Lifecycle:
///   1. `setupRime(_:)` — one-time global init (calls
///      `InitGoogleLogging` under the hood; must run exactly once
///      per process, hence the `setupLock` + `isFirstRun` guard).
///   2. `start(_:)` — opens a session, optionally runs maintenance.
///   3. Per-keystroke: `inputKey(_:)` / `inputKeyCode(_:modifier:)`,
///      then read `candidateList()` / `getCommitText()`.
///   4. `shutdown()` — destroys the session and finalizes librime.
///
/// All public methods are main-actor-agnostic; callers are
/// responsible for serializing access if they share the session
/// across threads.
public class Rime: LRKNotificationDelegate {

  // MARK: - Logger

  let logger = Logger(
    subsystem: "com.moocat.input.librime",
    category: "Rime"
  )

  // MARK: - Singleton

  /// Process-wide shared instance. librime itself is a singleton
  /// (global state inside the C library), so wrapping it in
  /// anything else would just paper over a hard constraint.
  public static let shared: Rime = .init()

  // MARK: - Callback typealiases

  typealias DeployCallbackFunction = () -> Void
  typealias ChangeCallbackFunction = (String) -> Void

  // MARK: - State (module-internal so Rime+*.swift extensions can touch it)

  /// Has `setupRime` already been invoked once in this process?
  /// Guard for `InitGoogleLogging` which crashes on a second call.
  var isFirstRun = true

  /// Serializes access to `isFirstRun` and `rimeAPI.setup()` so
  /// concurrent Tasks cannot race on `InitGoogleLogging()`.
  let setupLock = NSLock()

  /// Last traits the engine was started with — kept around so
  /// callers can re-issue the same config without re-deriving it.
  var traits: LRKTraits?

  /// Active rime session id. `0` means no session is open.
  var session: RimeSessionId = 0

  /// Cached simplified-Chinese mode toggle. The setter mirrors
  /// what was last written so consumers can read it without a
  /// round-trip through librime.
  var currentSimplifiedModeKey: String = ""
  var currentSimplifiedModeValue: Bool = false

  /// Underlying ObjC bridge to librime.
  let rimeAPI = LRKAPI()

  // MARK: - Notification callbacks (storage; setters live in Rime+Notifications.swift)

  var deployStartCallback: DeployCallbackFunction?
  var deploySuccessCallback: DeployCallbackFunction?
  var deployFailureCallback: DeployCallbackFunction?
  var changeModeCallback: ChangeCallbackFunction?
  var loadingSchemaCallback: ChangeCallbackFunction?

  // MARK: - Init

  private init() {}

  // MARK: - API accessor

  /// Direct access to the underlying ObjC bridge. Most callers
  /// should prefer the typed Swift wrappers in the `Rime+*.swift`
  /// extension files; this is provided as an escape hatch for
  /// rare APIs the wrapper hasn't surfaced yet.
  public func API() -> LRKAPI {
    return rimeAPI
  }

  // MARK: - Traits

  /// Build a default traits object pointing at the given data
  /// directories. Callers can mutate the result before passing it
  /// to `start(_:)` if they need finer-grained control.
  public static func createTraits(sharedSupportDir: String, userDataDir: String, models: [String] = []) -> LRKTraits {
    let traits = LRKTraits()
    traits.sharedDataDir = sharedSupportDir
    traits.userDataDir = userDataDir
    traits.distributionCodeName = "Rime"
    traits.distributionName = "Rime"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // NOTE: setting `appName` makes a subsequent `rimeAPI.setup()` call
    // crash with `Check failed: !IsGoogleLoggingInitialized()` because
    // librime forwards setup to InitGoogleLogging which is not safe to
    // call twice. The first-run guard in `setupRime(_:)` is what keeps
    // this safe.
    traits.appName = "rime.moocat"
    if !models.isEmpty {
      traits.modules = models
    }
    return traits
  }
}

// MARK: - Option keys

extension Rime {
  static let asciiModeKey = "ascii_mode"
  static let simplifiedChineseKey = "simplification"
}

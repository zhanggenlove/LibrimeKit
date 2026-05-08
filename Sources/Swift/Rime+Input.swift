//
//  Rime+Input.swift
//  LibrimeKit
//
//  Per-keystroke input + caret manipulation.
//

import Foundation
@_exported import RimeKitObjC

public extension Rime {

  // MARK: - Key input

  /// Feed a single character (as a one-char string) to librime.
  /// Returns whether librime consumed the key — `false` means the
  /// caller should pass the key through to its document directly.
  func inputKey(_ key: String) -> Bool {
    createSession()
    return rimeAPI.processKey(key, andSession: session)
  }

  /// Feed an X11 keycode + modifier mask. This is the lower-level
  /// path; use it for non-printable keys (BackSpace, Page_Up, etc.)
  /// or when the schema needs the precise X keysym.
  func inputKeyCode(_ keycode: Int32, modifier: Int32 = 0) -> Bool {
    createSession()
    return rimeAPI.processKeyCode(keycode, modifier: modifier, andSession: session)
  }

  // MARK: - Composition

  /// Read the raw input buffer librime is composing with.
  func getInputKeys() -> String {
    return rimeAPI.getInput(session)
  }

  /// Discard the in-progress composition without committing.
  func cleanComposition() {
    rimeAPI.cleanComposition(session)
  }

  // MARK: - Caret

  func getCaretPosition() -> Int {
    Int(rimeAPI.getCaretPosition(session))
  }

  func setCaretPosition(_ position: Int) {
    rimeAPI.setCaret(session, withPosition: Int32(position))
  }
}

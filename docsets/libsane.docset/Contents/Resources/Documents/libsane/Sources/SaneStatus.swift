import Clibsane

/// Different status codes and errors
public enum SaneStatus: Int, Error {
  /**
   The status codes used by SANE

   - seealso: [SANE documentation for Status type](http://sane.alioth.debian.org/html/doc011.html#s4.2.7)
   */
  case good, unsupported, cancelled, busy, invalid, jammed, EOF, noDocs, coverOpen, IOError, noMem, accessDenied
  /// additional errors, introduced by this module
  case notInitialized, unknown
}

extension SaneStatus: CustomStringConvertible {
  /// Use the textual status representation provided by SANE as description
  public var description: String {
    return strStatus()
  }
  private func strStatus() -> String {
    let tmp = SANE_Status(UInt32(self.rawValue))
    return String(cString: sane_strstatus(tmp))
  }
}

/// Additional errors which can occur with pointers
public enum PointerError: Int, Error {
  /// A number does not meet certain constraints
  case negative, toBig, toSmall
}

import Clibsane

extension SANE_Status: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: UInt32) {
    self.rawValue = value
  }
}

/// The status codes returned by SANE
public enum Status: SANE_Status, Error {
  case good, unsupported, cancelled, busy, inval, eof, jammed, noDocs, coverOpen, IOError, noMem, accessDenied
}

extension Status: CustomStringConvertible {
  /// Use the textual status representation provided by SANE as description
  public var description: String {
    return String(cString: sane_strstatus(self.rawValue))
  }
}

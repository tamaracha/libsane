import Clibsane

/// Conform toExpressibleByIntegerLiteral
extension SANE_Status: ExpressibleByIntegerLiteral {
  /// Initialize SANE_Status with an integer literal
  public init(integerLiteral value: UInt32) {
    self.rawValue = value
  }
}

/// This contains the SANE status codes
public enum Status: SANE_Status, Error {
  /// The status codes returned by SANE
  case good, unsupported, cancelled, busy, inval, eof, jammed, noDocs, coverOpen, IOError, noMem, accessDenied
}

extension Status: CustomStringConvertible {
  /// Use the textual status representation provided by SANE as description
  public var description: String {
    return String(cString: sane_strstatus(self.rawValue))
  }
}

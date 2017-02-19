import Clibsane

extension SANE_Status: CustomStringConvertible, Error {
  /// Use the textual status representation provided by SANE as description
  public var description: String {
    return String(cString: sane_strstatus(self))
  }
}

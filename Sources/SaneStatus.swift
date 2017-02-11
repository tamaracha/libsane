import Clibsane

public enum SaneStatus: Int, Error {
  case good, unsupported, cancelled, busy, invalid, jammed, EOF, noDocs, coverOpen, IOError, noMem, accessDenied, notInitialized, unknown
}

extension SaneStatus: CustomStringConvertible {
  public var description: String {
    return strStatus()
  }
  private func strStatus() -> String {
    let tmp = SANE_Status(UInt32(self.rawValue))
    return String(cString: Clibsane.sane_strstatus(tmp))
  }
}

public enum PointerError: Int, Error {
  case negative
  case toBig
  case toSmall
}

import Clibsane

protocol Capable: OptionSet {
  func canRead() throws
  func canWrite() throws
  func canAutoset() throws
}

struct Capabilities: Capable {
  enum CapError: Error {
    case read, write, autoset
  }

  let rawValue: SANE_Int
  init(rawValue: SANE_Int) {
    self.rawValue = rawValue
  }
  static let softSelect = Capabilities(rawValue: SANE_CAP_SOFT_SELECT)
  static let hardSelect = Capabilities(rawValue: SANE_CAP_HARD_SELECT)
  static let softDetect = Capabilities(rawValue: SANE_CAP_SOFT_DETECT)
  static let emulated = Capabilities(rawValue: SANE_CAP_EMULATED)
  static let automatic = Capabilities(rawValue: SANE_CAP_AUTOMATIC)
  static let inactive = Capabilities(rawValue: SANE_CAP_INACTIVE)
  static let advanced = Capabilities(rawValue: SANE_CAP_ADVANCED)
  var isReadable: Bool {
    return self.contains(.softDetect) && !self.contains(.inactive)
  }
  var isWritable: Bool {
    return self.contains(.softSelect) && !self.contains(.inactive)
  }
  var isAutosettable: Bool {
    return self.contains([.softSelect, .automatic]) && !self.contains(.inactive)
  }
  func canRead() throws {
    guard self.isReadable else {
      throw CapError.read
    }
  }
  func canWrite() throws {
    guard self.isWritable else {
      throw CapError.write
    }
  }
  func canAutoset() throws {
    guard self.isAutosettable else {
      throw CapError.autoset
    }
  }
}

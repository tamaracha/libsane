import Clibsane

protocol Optionable {}
extension Bool: Optionable {}
extension Int: Optionable {}
extension Double: Optionable {}
extension String: Optionable {}

class SaneOption {
  //MARK: Types
  enum ValueType: Int {
    case Bool, Int, Fixed, String, Button, Group
  }
  
  enum Unit: Int {
    case none, pixel, bit, mm, dpi, percent, microsecond
  }
  
  struct Cap: OptionSet {
    let rawValue: Int
    static let softSelect = Cap(rawValue: 1 << 0)
    static let hardSelect = Cap(rawValue: 1 << 1)
    static let hardDetect = Cap(rawValue: 1 << 2)
    static let emulated = Cap(rawValue: 1 << 3)
    static let automatic = Cap(rawValue: 1 << 4)
    static let inactive = Cap(rawValue: 1 << 5)
    static let advanced = Cap(rawValue: 1 << 6)
  }

  //MARK: Properties
  let name: String
  let title: String
  let desc: String
  let type: ValueType
  let unit: Unit
  let size: Int
  let cap: Cap
  let constraintType: Int
  let constraint: Int
  var value: Optionable

  //MARK: Lifecycle Hooks
  init(from saneValue: SANE_Option_Descriptor) {
    name = String(cString: saneValue.name)
    title = String(cString: saneValue.title)
    desc = String(cString: saneValue.desc)
    type = ValueType(rawValue: Int(saneValue.type.rawValue))!
    unit = Unit(rawValue: Int(saneValue.unit.rawValue))!
    size = 0
    cap = Cap(rawValue: Int(saneValue.cap))
    constraintType = 0
    constraint = 0
    value = 0
  }
}

extension SaneOption: CustomStringConvertible {
  var description: String {
    return desc
  }
}

extension SaneOption: Hashable {
  var hashValue: Int {
    return self.name.hashValue
  }
  static func ==(lhs: SaneOption, rhs: SaneOption) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

import Clibsane

class NumericOption: BaseOption, Changeable {
  typealias `Self` = NumericOption
  //MARK: Statics for fixed point numbers
  static let shift = Double(0b1 << 16)
  static func fix(_ d: Double) -> Int32 {
    return Int32(d*shift)
  }
  static func unfix(_ n: Int32) -> Double {
    return Double(n)/shift
  }
  var value: Double {
    get {
      return 0.0
    }
    set {
      
    }
  }
  func getValue() throws -> Double {
    let (handle, index) = try checkHandle()
    var saneValue: Int32 = 0
    let status = Int(sane_control_option(handle, index, SANE_Action(0), &saneValue, nil).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    return Self.unfix(saneValue)
  }
  func setValue(value: Double) throws -> (value: Double, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue = Self.fix(value)
    var saneInfo: Int32 = 0
    let status = Int(sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    return (value: Self.unfix(saneValue), info: Info(rawValue: Int(saneInfo)))
  }
}

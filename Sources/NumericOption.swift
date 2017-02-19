import Clibsane

class NumericOption: BaseOption, Changeable {
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
    let status = sane_control_option(handle, index, SANE_Action(0), &saneValue, nil).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return saneValue.unfixed()
  }
  func setValue(value: Double) throws -> (value: Double, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue = value.fixed()
    var saneInfo: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return (value: saneValue.unfixed(), info: Info(rawValue: saneInfo))
  }
}

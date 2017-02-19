import Clibsane

class SwitchOption: BaseOption, Changeable {
  var value = false
  func getValue() throws -> Bool {
    let (handle, index) = try checkHandle()
    var saneValue: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(0), &saneValue, nil).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return Int(saneValue) == 1
  }
  func setValue(value: Bool) throws -> (value: Bool, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue: Int32 = value ? 1 : 0
    var saneInfo: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return (value: Int(saneValue) == 1, info: Info(rawValue: saneInfo))
  }
}

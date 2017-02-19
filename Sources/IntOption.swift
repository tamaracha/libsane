import Clibsane

class IntOption: BaseOption, Changeable {
  var value = 0
  func getValue() throws -> Int {
    let (handle, index) = try checkHandle()
    var saneValue: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(0), &saneValue, nil).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return Int(saneValue)
  }
  func setValue(value: Int) throws -> (value: Int, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue = Int32(value)
    var saneInfo: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return (value: Int(saneValue), info: Info(rawValue: saneInfo))
  }
}

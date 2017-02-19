import Clibsane

class IntOption: BaseOption, Changeable {
  var value = 0
  func getValue() throws -> Int {
    let (handle, index) = try checkHandle()
    var saneValue: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(0), &saneValue, nil)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    return Int(saneValue)
  }
  func setValue(value: Int) throws -> (value: Int, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue = Int32(value)
    var saneInfo: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    return (value: Int(saneValue), info: Info(rawValue: saneInfo))
  }
}

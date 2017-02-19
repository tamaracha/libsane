import Clibsane

class TextOption: BaseOption, Changeable {
  var value: String {
    get {
      return "hallo"
    }
    set {
      
    }
  }
  func getValue() throws -> String {
    let (handle, index) = try checkHandle()
    var saneValue = ""
    let status = sane_control_option(handle, index, SANE_Action(0), &saneValue, nil).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return saneValue
  }
  func setValue(value: String) throws -> (value: String, info: Info) {
    let (handle, index) = try checkHandle()
    var saneValue = value
    var saneInfo: Int32 = 0
    let status = sane_control_option(handle, index, SANE_Action(1), &saneValue, &saneInfo).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
    return (value: saneValue, info: Info(rawValue: saneInfo))
  }
}

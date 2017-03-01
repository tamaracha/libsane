import Clibsane

/// An option with a binary value
class SwitchOption: BaseOption, Changeable {
  //MARK: Properties
  var value = false

  //MARK: Lifecycle
  override init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    super.init(from: descriptor, at: index, of: device)
  }

  func toSane(_ value: Bool) -> SANE_Bool {
    return value ? SANE_TRUE : SANE_FALSE
  }
  func fromSane(_ saneValue: SANE_Bool) -> Bool {
    switch saneValue {
    case SANE_FALSE:
      return false
    case SANE_TRUE:
      return true
    default:
      return false
    }
  }
  //MARK: Methods for Changeable
  func getValue() throws -> Bool {
    try cap.canRead()
    var saneValue: SANE_Bool = SANE_FALSE
    try device?.getValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
  func setValue(_ value: Bool) throws -> Bool {
    try cap.canWrite()
    var saneValue = toSane(value)
    try device?.setValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
}

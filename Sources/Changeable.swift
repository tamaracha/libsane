import Clibsane

protocol Changeable: OptionController {
  associatedtype Value
  var value: Value { get set }
  func getValue() throws -> Value
  func setValue(value: Value) throws -> (value: Value, info: Info)
  func setAuto() throws
}

extension Changeable {
  func setAuto() throws {
    let (handle, index) = try checkHandle()
    let status = sane_control_option(handle, index, SANE_Action(2), nil, nil).rawValue
    guard status == 0 else {
      throw StatusCode(rawValue: status)!
    }
  }
}

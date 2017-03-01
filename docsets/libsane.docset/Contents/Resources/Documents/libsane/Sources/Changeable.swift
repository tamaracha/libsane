import Clibsane

protocol Changeable: Option {
  associatedtype Value
  associatedtype SaneValue
  var value: Value { get set }
  func fromSane(_ saneValue: SaneValue) -> Value
  func setAuto() throws
  func getValue() throws -> Value
  func setValue(_ value: Value) throws -> Value
}

extension Changeable {
  func setAuto() throws {
    try cap.canAutoset()
    try device?.setAuto(at: index)
  }
}

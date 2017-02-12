protocol Toggleable: Changeable {
  var value: Bool { get set }
  mutating func toggle()
}
extension Toggleable {
  mutating func toggle() {
    value = !value
  }
}

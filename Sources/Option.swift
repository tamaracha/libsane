import Clibsane

protocol Option {
  associatedtype OptionError
  associatedtype Unit
  associatedtype Cap: Capable = Capabilities
  var cap: Self.Cap { get }
  var unit: Unit? { get }
  var index: SANE_Int { get }
  weak var device: Device? {get }
}

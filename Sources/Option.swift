import Clibsane

protocol Option {
  var index: SANE_Int { get }
  weak var device: Device? { get set }
  var cap: BaseOption.Cap { get }
  var isReadable: Bool { get }
  var isWritable: Bool { get }
  var isautosetable: Bool { get }
}

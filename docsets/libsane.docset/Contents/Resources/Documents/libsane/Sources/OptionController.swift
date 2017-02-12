import Clibsane

protocol OptionController {
  var descriptor: OptionDescriptor { get set }
  func checkHandle() throws -> (SANE_Handle, Int32)
}

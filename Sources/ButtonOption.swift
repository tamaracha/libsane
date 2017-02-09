import Clibsane

struct ButtonOption: Pressable, Option {
  //MARK: Option conformance
  let descriptor: OptionDescriptor
  let index: Int32
  weak var device: SaneDevice!

  func press() {
    
  }
}

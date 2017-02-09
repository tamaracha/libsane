class BaseOption {
  //MARK: Properties
  var descriptor: OptionDescriptor
  let index: Int32
  weak var device: SaneDevice!
  //MARK: Lifecycle
  init(from descriptor: OptionDescriptor, at index: Int32, of device: SaneDevice) {
    self.descriptor = descriptor
    self.index = index
    self.device = device
  }
}

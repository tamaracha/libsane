import Clibsane

public class BaseOption: OptionController {
  enum OptionError: Int, Error {
    case noDevice
    case noHandle
    case noValue
  }

  //MARK: Properties
  var descriptor: OptionDescriptor
  let index: Int32
  private weak var device: Device!
  //MARK: Lifecycle
  init(from descriptor: OptionDescriptor, at index: Int32, of device: Device) {
    self.descriptor = descriptor
    self.index = index
    self.device = device
  }
  func checkHandle() throws -> (SANE_Handle, Int32) {
    guard let state = device?.state else {
      throw OptionError.noDevice
    }
    guard case let .open(handle) = state else {
      throw OptionError.noHandle
    }
    return (handle, index)
  }
}

extension BaseOption: CustomStringConvertible {
  public var description: String {
    return descriptor.description
  }
}

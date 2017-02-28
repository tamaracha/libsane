import Clibsane

public class BaseOption: Option {
  //MARK: Types
  public enum OptionError: Error {
    case noDevice
    case noValue
    case invalid
  }

  public enum Unit: UInt32 {
    case none, pixel, bit, mm, dpi, percent, microsecond
  }

  //MARK: Properties
  public let name, title, desc: String
  public let unit: Unit
  var cap: Capabilities
  let index: SANE_Int
  weak var device: Device?

  //MARK: Lifecycle
  init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    name = String(cString: descriptor.name)
    title = String(cString: descriptor.title)
    desc = String(cString: descriptor.desc)
    unit = Unit(rawValue: descriptor.unit.rawValue)!
    cap = Capabilities(rawValue: descriptor.cap)

    self.index = index
    self.device = device
  }
  func update(_ descriptor: SANE_Option_Descriptor) {
  cap = Capabilities(rawValue: descriptor.cap)
  }
}

extension BaseOption: CustomStringConvertible {
  public var description: String {
    return "\(name): \(desc)"
  }
}

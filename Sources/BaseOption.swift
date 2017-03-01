import Clibsane

/// A basic option which is subclassed by the other option types
public class BaseOption: Option {
  //MARK: Types
  /// option-specific errors
  public enum OptionError: Error {
    /// The device is lost due to weak variable
    case noDevice
    /// The value to be set does not conform to its constraints
    case invalid
  }

  /// Units for number values
  public enum Unit: UInt32 {
    /// A pixel or similar measurement
    case pixel = 1
    /// A bit (information) measurement
    case bit
    /// A length measurement in mm
    case mm
    /// A resolution measurement in dpi
    case dpi
    /// A percentage measurement
    case percent
    /// A time measurement in microseconds
    case microsecond
  }

  //MARK: Properties
  /// The unique name, one-line-title, and multi-line-description of the option
  public let name, title, desc: String
  /// The unit of the option value
  public let unit: Unit?
  var cap: Capabilities
  let index: SANE_Int
  weak var device: Device?

  //MARK: Lifecycle
  init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    name = String(cString: descriptor.name)
    title = String(cString: descriptor.title)
    desc = String(cString: descriptor.desc)
    unit = Unit(rawValue: descriptor.unit.rawValue)
    cap = Capabilities(rawValue: descriptor.cap)

    self.index = index
    self.device = device
  }
  func update(_ descriptor: SANE_Option_Descriptor) {
  cap = Capabilities(rawValue: descriptor.cap)
  }
}

extension BaseOption: CustomStringConvertible {
  /// A textual representation composed of name and desc
  public var description: String {
    return "\(name): \(desc)"
  }
}

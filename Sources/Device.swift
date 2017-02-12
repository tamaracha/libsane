import Clibsane

/// Represents a SANE device.
public class Device {
  //MARK: Types
  enum State {
    case disconnected
    case connected
    case open(handle: SANE_Handle)
  }

  //MARK: Properties
  /// Properties which describe a SANE device
  public let name, vendor, model, type: String

  private(set) var state: State = .connected
  private(set) var options = [String: OptionController]()

  //MARK: Lifecycle Hooks
  init(name: String, vendor: String, model: String, type: String) {
    self.name = name
    self.vendor = vendor
    self.model = model
    self.type = type
  }
  init(from device: SANE_Device) {
    name = String(cString: device.name)
    vendor = String(cString: device.vendor)
    model = String(cString: device.model)
    type = String(cString: device.type)
  }

  //MARK: Methods
  func open() throws {
    var handle: SANE_Handle?
    let status = Int(sane_open(name, &handle).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    if let handle = handle {
      state = .open(handle: handle)
    }
  }

  func close() {
    if case let .open(handle) = state {
      sane_close(handle)
    }
    state = .connected
  }

  func getOptions() throws {
    guard case let .open(handle) = state else {
      return
    }
    let count = UnsafeRawPointer(sane_get_option_descriptor(handle, Int32(0))).assumingMemoryBound(to: Int32.self)
    guard count.pointee >= 0 else {
      throw PointerError.negative
    }
    guard count.pointee >= 1 else {
      throw PointerError.toSmall
    }
    for index in 1 ... count.pointee-1 {
      let saneOption = sane_get_option_descriptor(handle, index).pointee
      guard let descriptor = OptionDescriptor(from: saneOption) else {
        break
      }
      var option: OptionController
      switch descriptor.valueType {
      case .bool:
        option = SwitchOption(from: descriptor, at: index, of: self)
      case .int:
        option = IntOption(from: descriptor, at: index, of: self)
      case .fixed:
        option = NumericOption(from: descriptor, at: index, of: self)
      case .string:
        option = TextOption(from: descriptor, at: index, of: self)
      case .button:
        option = ButtonOption(from: descriptor, at: index, of: self)
      default:
        option = BaseOption(from: descriptor, at: index, of: self)
      }
      options[option.descriptor.name] = option
    }
  }

}

//MARK: Extensions
extension Device: CustomStringConvertible {
  /// use the device name as description
  public var description: String {
    return name
  }
}

extension Device: Hashable {
  /// use the device name as hash value
  public var hashValue: Int {
    return name.hashValue
  }
  /// Devices can be equated by their hash value
  static public func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

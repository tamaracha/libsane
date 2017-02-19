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
  public let name, model, vendor, type: String

  private(set) var state: State = .connected
  public private(set) var options = [String: BaseOption]()

  //MARK: Lifecycle Hooks
  init(_ name: String, model: String, vendor: String, type: String) {
    self.name = name
    self.vendor = vendor
    self.model = model
    self.type = type
  }
  convenience init(_ name: String) {
    self.init(name, model: "unknown", vendor: "Noname", type: "virtual device")
  }
  init(from device: SANE_Device) {
    name = String(cString: device.name)
    model = String(cString: device.model)
    vendor = String(cString: device.vendor)
    type = String(cString: device.type)
  }
  deinit {
close()
}

  //MARK: Methods
  public func open() throws {
    var tmpHandle: SANE_Handle?
    let status = sane_open(name, &tmpHandle)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    if let handle = tmpHandle {
      state = .open(handle: handle)
    }
    try getOptions()
  }

  public func close() {
    if case let .open(handle) = state {
      sane_close(handle)
    }
    state = .connected
  }

  func getOptions() throws {
    guard case let .open(handle) = state else {
      throw BaseOption.OptionError.noHandle
    }
    var count: Int32 = 1
    let status = sane_control_option(handle, Int32(0), SANE_Action(0), &count, nil)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    guard count > 1 else {
      return
    }
    for index in Int32(1) ... count-1 {
      let saneOption = sane_get_option_descriptor(handle, index).pointee
      guard let descriptor = OptionDescriptor(from: saneOption) else {
        continue
      }
      var option: BaseOption
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

  func reloadOptions() {
  guard case let .open(handle) = state else {
  return
  }
  for (name, option) in options {
    let saneOption = sane_get_option_descriptor(handle, option.index).pointee
    guard let descriptor = OptionDescriptor(from: saneOption) else {
      break
    }
    options[name]?.descriptor = descriptor
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

extension Device: Hashable, Comparable {
  /// use the device name as hash value
  public var hashValue: Int {
    return name.hashValue
  }
  /// Devices can be equated by their hash value
  public static func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  public static func <(lhs: Device, rhs: Device) -> Bool {
    return lhs.name < rhs.name
  }
}

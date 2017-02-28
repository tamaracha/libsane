import Clibsane

/// Represents a SANE device.
public class Device {
  //MARK: Types
  public enum DeviceError: Error {
case noHandle
}

  public enum State {
    case disconnected
    case connected
    case open
  }

  /**
   An additional information bitset which is returned after setting a device option. It is implemented as a OptionSet for better swift integration.
   
   - seealso: http://sane.alioth.debian.org/html/doc012.html
   */
  struct Info: OptionSet {
    let rawValue: Int32
    /// The given value couldn't be set exactly, but the nearest aproximate value is used
    static let inexact = Info(rawValue: SANE_INFO_INEXACT)
    /// The option descriptors may have changed
    static let reloadOptions = Info(rawValue: SANE_INFO_RELOAD_OPTIONS)
    /// the device parameters may have changed.
    static let reloadParams = Info(rawValue: SANE_INFO_RELOAD_PARAMS)
  }

  /// This constant is used as maximal buffer size when reading image data
  static private let bufferSize = 1024*1024
  //MARK: Properties
  /// Properties which describe a SANE device
  public let name, model, vendor, type: String

  public private(set) var state: State = .connected
  public private(set) var options = [String: BaseOption]()
  private var handle: SANE_Handle? {
    didSet {
      state = handle == nil ? .connected : .open
    }
  }

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
    var handle: SANE_Handle?
    let status = sane_open(name, &handle)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    self.handle = handle
    if state == .open {
      try getOptions()
    }
  }

  public func close() {
    if let handle = handle {
      sane_close(handle)
    }
    handle = nil
    options.removeAll()
  }

  func getOptions() throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    var count: SANE_Int = 1
    let status = sane_control_option(handle, 0, SANE_ACTION_GET_VALUE, &count, nil)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    guard count > 1 else {
      return
    }
    for index in 1 ... count-1 {
      let descriptor = sane_get_option_descriptor(handle, index).pointee
      var option: BaseOption
      switch descriptor.type {
      case SANE_TYPE_BOOL:
        option = SwitchOption(from: descriptor, at: index, of: self)
      case SANE_TYPE_INT:
        option = IntOption(from: descriptor, at: index, of: self)
      case SANE_TYPE_FIXED:
        option = NumericOption(from: descriptor, at: index, of: self)
      case SANE_TYPE_STRING:
        option = TextOption(from: descriptor, at: index, of: self)
      case SANE_TYPE_BUTTON:
        option = ButtonOption(from: descriptor, at: index, of: self)
      case SANE_TYPE_GROUP:
        continue
      default:
        continue
      }
      options[option.name] = option
    }
  }

  func reloadOptions() throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
  for (_, option) in options {
    let descriptor = sane_get_option_descriptor(handle, option.index).pointee
    option.update(descriptor)
  }
  }

  func setAuto(at index: SANE_Int) throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    let status = sane_control_option(handle, index, SANE_ACTION_SET_AUTO, nil, nil)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
  }
  func getValue(at index: SANE_Int, to ptr: UnsafeMutableRawPointer) throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    let status = sane_control_option(handle, index, SANE_ACTION_GET_VALUE, ptr, nil)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
  }
  func setValue(at index: SANE_Int, to ptr: UnsafeMutableRawPointer) throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    var saneInfo: SANE_Int = 0
    let status = sane_control_option(handle, index, SANE_ACTION_SET_VALUE, ptr, &saneInfo)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    let info = Info(rawValue: saneInfo)
    if info.contains(.reloadOptions) {
      try reloadOptions()
    }
  }

  public func getParameters() throws -> Parameters {
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    var params = SANE_Parameters()
    let status = sane_get_parameters(handle, &params)
    guard status == SANE_STATUS_GOOD else {
      throw status
    }
    return Parameters(params)
  }
  private func start() throws {
    guard case .open = state else {
      return
    }
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    let status = sane_start(handle)
    guard status == SANE_STATUS_GOOD else {
throw status
}
  }
  private func setAsync() throws -> Bool {
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    let status = sane_set_io_mode(handle, SANE_TRUE)
    if status == SANE_STATUS_GOOD {
      return true
    }
    else if status == SANE_STATUS_UNSUPPORTED {
      return false
    } else {
      throw status
    }
  }
  private func read(frameSize: Int? = nil, maxLen: Int = Device.bufferSize) throws -> [SANE_Byte] {
    guard let handle = handle else {
      throw DeviceError.noHandle
    }
    var data = [SANE_Byte]()
    var buf = [SANE_Byte](repeating: 0, count: maxLen)
    var status: SANE_Status
    var n: SANE_Int = 0
    if let frameSize = frameSize {
      repeat {
        status = sane_read(handle, &buf, SANE_Int(maxLen), &n)
        data += buf.prefix(Int(n))
  } while status == SANE_STATUS_GOOD && data.count < frameSize
}
    else {
      repeat {
        status = sane_read(handle, &buf, SANE_Int(maxLen), &n)
        data += buf.prefix(Int(n))
      } while status == SANE_STATUS_GOOD
    }
    guard status == SANE_STATUS_EOF || status == SANE_STATUS_GOOD else {
      throw status
    }
    return data
}
  public func cancel() {
    guard case .open = state else {
      return
    }
    if let handle = handle {
      sane_cancel(handle)
    }
}
  public func scan() throws -> (data: [SANE_Byte], params: Parameters) {
    try start()
    let params = try getParameters()
    let data = try read(frameSize: params.bytesTotal)
    cancel()
    return (data: data, params: params)
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
}

extension Device: Comparable {
  /// Devices can be equated by their hash value
  static public func ==(lhs: Device, rhs: Device) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  static public func <(lhs: Device, rhs: Device) -> Bool {
    return lhs.hashValue < rhs.hashValue
  }
}

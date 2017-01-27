import Clibsane

class SaneDevice {
  //MARK: Types
  enum State {
    case disconnected
    case connected
    case open(handle: SANE_Handle)
  }

  //MARK: Properties
  let name: String
  let vendor: String
  let model: String
  let type: String
  var state: State = .connected
  var options = [String: SaneOption]()

  //MARK: Lifecycle Hooks
  init(name: String, vendor: String, model: String, type: String) {
    self.name = name
    self.vendor = vendor
    self.model = model
    self.type = type
  }
  convenience init(_ device: SANE_Device) {
    self.init(
      name: String(cString: device.name),
      vendor:String(cString: device.vendor),
      model:String(cString: device.model),
      type:String(cString: device.type)
    )
  }

  //MARK: Methods
  func open() throws {
    var handle: SANE_Handle?
    let status = Int(Clibsane.sane_open(name, &handle).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    if let handle = handle {
      state = .open(handle: handle)
    }
  }

  func close() {
    if case let .open(handle) = state {
      Clibsane.sane_close(handle)
    }
    state = .connected
  }

  func getOptions() throws {
    if case let .open(handle) = state {
      let count = UnsafeRawPointer(Clibsane.sane_get_option_descriptor(handle, Int32(0))).assumingMemoryBound(to: Int32.self)
      guard count.pointee >= 0 else {
        throw PointerError.negative
      }
      guard count.pointee >= 1 else {
        throw PointerError.toSmall
      }
      for index in 1 ... count.pointee-1 {
        let option = SaneOption(from: Clibsane.sane_get_option_descriptor(handle, index).pointee)
        options[option.name] = option
      }
    }
  }

}

extension SaneDevice: CustomStringConvertible {
  var description: String {
    return "\(model), \(type), \(name), \(vendor)"
  }
}

extension SaneDevice: Hashable {
  var hashValue: Int {
    return self.name.hashValue
  }
  static func ==(lhs: SaneDevice, rhs: SaneDevice) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

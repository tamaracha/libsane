import Clibsane

/// The entry class for this module
final public class LibSane {
  /// An instance of LibSane itself. It inits and exits the SANE backend during init and deinit.
  static let shared = LibSane()

  //MARK: Properties
  /// The version of SANE. It is set during initialization.
  let version: Version

  //MARK: Lifecycle hooks
  private init?() {
    var version: Int32 = 0
    let status = Int(sane_init(&version, nil).rawValue)
    guard status == 0 else {
      return nil
    }
    self.version = Version(version)
  }
  deinit {
    sane_exit()
  }

  //MARK: Static methods
  /**
   This function can be used to search for connected SANE devices

   - parameter localOnly: skips network devices in search, defaults to false
   - returns: the found devices as a dictionary, where a device can be accessed by its name
   */
  public static func getDevices(localOnly: Bool = false) throws -> [String: Device] {
    guard shared != nil else {
      throw SaneStatus.notInitialized
    }
    var tmpPointer: UnsafeMutablePointer<UnsafePointer<SANE_Device>?>?
    let status = Int(sane_get_devices(&tmpPointer, Int32(localOnly ? 1 : 0)).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    var devices = [String: Device]()
    guard var pointer = tmpPointer else {
      return devices
    }
    while pointer.pointee != nil {
      if let el = pointer.pointee?.pointee {
        let device = Device(from: el)
        devices[device.name] = device
      }
      pointer = pointer.successor()
    }
    return devices
  }
}

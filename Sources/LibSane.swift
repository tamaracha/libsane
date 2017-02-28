import Clibsane

/// The entry class for this module
final public class LibSane {
  /// An instance of LibSane itself. It inits and exits the SANE backend during init and deinit.
  private static let shared: LibSane? = LibSane()

  //MARK: Properties
  /// The SANE version. It is set during initialization.
  private let version: Version

  //MARK: Lifecycle hooks
  private init?() {
    var versionCode: SANE_Int = 0
    let status = sane_init(&versionCode, nil)
    guard status == SANE_STATUS_GOOD else {
      return nil
    }
    version = Version(versionCode)
  }
  deinit {
    sane_exit()
  }

  //MARK: Statics
  /// The SANE version if initialization was successful
  public static var version: Version? {
    return shared?.version
  }
  /**
   This function can be used to search for connected SANE devices, if initialization was successful

   - parameter localOnly: skips network devices in search, defaults to false
   - returns: either the found devices as a dictionary, where a device can be accessed by its name, or nil if not initialized
   - complexity: very high
   */
  public static func getDevices(localOnly: Bool = false) throws -> [String: Device]? {
    guard shared != nil else {
      return nil
    }
    var tmpPointer: UnsafeMutablePointer<UnsafePointer<SANE_Device>?>?
    let status = sane_get_devices(&tmpPointer, localOnly ? SANE_TRUE : SANE_FALSE)
    guard status == SANE_STATUS_GOOD else {
      throw status
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

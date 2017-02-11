import Clibsane

final public class LibSane {
  /// Singleton due to hardware communication
  static let shared = LibSane()

  //MARK: Properties
  let version: Version

  //MARK: Lifecycle hooks
  init?() {
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

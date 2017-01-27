import Clibsane

final public class SaneApi {
  // Singleton due to hardware communication
  static let shared = SaneApi()

  //MARK: Properties
  let version: SaneVersion
  var devices = [String:SaneDevice]()

  //MARK: Lifecycle hooks
  init?() {
    var version: Int32 = 0
    let status = Int(Clibsane.sane_init(&version, nil).rawValue)
    guard status == 0 else {
      return nil
    }
    self.version = SaneVersion(version)
  }
  deinit {
    Clibsane.sane_exit()
  }

  //MARK: Methods
  public func getDevices(localOnly: Bool = false) throws {
    var device_list: UnsafeMutablePointer<UnsafePointer<SANE_Device>?>?
    let status = Int(Clibsane.sane_get_devices(&device_list, Int32(localOnly ? 1 : 0)).rawValue)
    guard status == 0 else {
      throw SaneStatus(rawValue: status)!
    }
    while device_list?.pointee != nil {
      if let el = device_list?.pointee?.pointee {
        let device = SaneDevice(el)
        devices[device.name] = device
      }
      device_list = device_list?.successor()
    }
  }
}

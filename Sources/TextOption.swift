import Clibsane

public class TextOption: BaseOption {
  //MARK: Properties
  public let size: Int
  public let constraint: [String]?
  public var value = "hallo"

  //MARK: Lifecycle
  override init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    size = Int(descriptor.size)
    switch descriptor.constraint_type {
    case SANE_CONSTRAINT_NONE:
      constraint = nil
    case SANE_CONSTRAINT_STRING_LIST:
      guard var itemPointer = descriptor.constraint.string_list else {
        constraint = nil
        break
      }
      var list = [String]()
      while itemPointer.pointee != nil {
        if let item = itemPointer.pointee {
          list.append(String(cString: item))
        }
        itemPointer = itemPointer.successor()
      }
      constraint = list
    default:
      constraint = nil
    }
    super.init(from: descriptor, at: index, of: device)
  }
}

extension TextOption: Changeable {
  func validate(_ value: String) -> Bool {
    if value.utf8CString.count > size {
      return false
    } else if let constraint = constraint {
      return constraint.contains(value)
    } else {
      return true
    }
  }
  func fromSane(_ saneValue: SANE_String_Const) -> String {
    return String(cString: saneValue)
  }
  public func getValue() throws -> String {
    try cap.canRead()
    let value = String(repeating: "x", count: size-1)
    return try value.withCString({ (ptr: SANE_String_Const) -> String in
      let saneValue: SANE_String = UnsafeMutablePointer(mutating: ptr)
      try device?.getValue(at: index, to: saneValue)
      return fromSane(saneValue)
    })
  }
  public func setValue(_ value: String) throws -> String {
    try cap.canWrite()
    guard validate(value) == true else {
      throw OptionError.invalid
    }
    return try value.withCString({ (ptr: SANE_String_Const) -> String in
      let saneValue: SANE_String = UnsafeMutablePointer(mutating: ptr)
      try device?.setValue(at: index, to: saneValue)
      return fromSane(saneValue)
    })
  }
}

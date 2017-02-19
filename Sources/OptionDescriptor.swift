import Clibsane

protocol Presentable: CustomStringConvertible {
  var name: String { get }
  var title: String { get }
  var desc: String { get }
}
extension Presentable {
  public var description: String {
    return "\(name): \(desc)"
  }
}

public struct OptionDescriptor: Presentable {
  //MARK: Types
  enum ValueType: Int {
    case bool, int, fixed, string, button, group
  }

  enum Unit: Int {
    case none, pixel, bit, mm, dpi, percent, microsecond
  }

  struct Cap: OptionSet {
    let rawValue: Int
    static let softSelect = Cap(rawValue: 1 << 0)
    static let hardSelect = Cap(rawValue: 1 << 1)
    static let hardDetect = Cap(rawValue: 1 << 2)
    static let emulated = Cap(rawValue: 1 << 3)
    static let automatic = Cap(rawValue: 1 << 4)
    static let inactive = Cap(rawValue: 1 << 5)
    static let advanced = Cap(rawValue: 1 << 6)
  }

  enum Constraint {
    case none
    case range(min: Double, max: Double, quant: Double)
    case numberList([Int])
    case stringList([String])
  }

  //MARK: Properties
  let name, title, desc: String
  let valueType: ValueType
  let unit: Unit
  let size: Int
  let cap: Cap
  let constraint: Constraint

  //MARK: Lifecycle
  init?(from saneValue: SANE_Option_Descriptor) {
    valueType = ValueType(rawValue: Int(saneValue.type.rawValue))!
    if case .group = valueType {
      return nil
    }
    name = String(cString: saneValue.name)
    title = String(cString: saneValue.title)
    desc = String(cString: saneValue.desc)
    unit = Unit(rawValue: Int(saneValue.unit.rawValue))!
    size = Int(saneValue.size)
    cap = Cap(rawValue: Int(saneValue.cap))
    switch saneValue.constraint_type {
    case SANE_CONSTRAINT_NONE:
      constraint = .none
      break
    case SANE_CONSTRAINT_RANGE:
      let range = saneValue.constraint.range.pointee
      switch valueType {
      case .int:
        constraint = .range(min: Double(range.min), max: Double(range.max), quant: Double(range.quant))
      case .fixed:
        constraint = .range(min: range.min.unfixed(), max: range.max.unfixed(), quant: range.quant.unfixed())
      default:
        print("option type neither int nor fixed")
        return nil
      }
    case SANE_CONSTRAINT_WORD_LIST:
      guard var itemPointer = saneValue.constraint.word_list else {
        constraint = .none
        break
      }
      var list = [Int]()
      let length = itemPointer.pointee
      for _ in 1 ... length {
        itemPointer = itemPointer.successor()
        list.append(Int(itemPointer.pointee))
      }
      constraint = .numberList(list)
    case SANE_CONSTRAINT_STRING_LIST:
      guard var itemPointer = saneValue.constraint.string_list else {
        constraint = .none
        break
      }
      var list = [String]()
      while itemPointer.pointee != nil {
        if let item = itemPointer.pointee {
          list.append(String(cString: item))
        }
        itemPointer = itemPointer.successor()
      }
      constraint = .stringList(list)
    default:
      constraint = .none
    }
  }
}

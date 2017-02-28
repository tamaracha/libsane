import Clibsane

public class IntOption: BaseOption {
  enum Constraint {
    case range(CountableClosedRange<Int>), quantRange(StrideThrough<Int>), list([Int])
  }

  //MARK: Properties
  public let size: Int
  let constraint: Constraint?
  public var value = [0]

  //MARK: Lifecycle
  override init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    size = Int(descriptor.size)/MemoryLayout<SANE_Int>.stride
    switch descriptor.constraint_type {
    case SANE_CONSTRAINT_NONE:
      constraint = nil
    case SANE_CONSTRAINT_RANGE:
      let range = descriptor.constraint.range.pointee
      let (min, max, quant) = (Int(range.min), Int(range.max), Int(range.quant))
      if quant == 0 {
        constraint = .range(min ... max)
      } else {
        constraint = .quantRange(stride(from: min, through: max, by: quant))
      }
    case SANE_CONSTRAINT_WORD_LIST:
      guard let ptr = descriptor.constraint.word_list else {
        constraint = nil
        break
      }
      constraint = .list([SANE_Int](UnsafeBufferPointer(start: ptr, count: Int(ptr.pointee))).dropFirst().map({Int($0)}))
    default:
      constraint = nil
    }
    super.init(from: descriptor, at: index, of: device)
  }
}

extension IntOption: Changeable {
  func fromSane(_ saneValue: [SANE_Int]) -> [Int] {
    return saneValue.map({Int($0)})
  }
  func toSane(_ value: [Int]) -> [SANE_Int] {
    return value.map({SANE_Int($0)})
  }
  public func getValue() throws -> [Int] {
    try cap.canRead()
    var saneValue = [SANE_Int](repeating: 0, count: size)
    try device?.getValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
  public func setValue(_ value: [Int]) throws -> [Int] {
    try cap.canWrite()
    guard value.count == size else {
      throw OptionError.invalid
    }
    var saneValue = toSane(value)
    try device?.setValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
}

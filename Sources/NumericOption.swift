import Clibsane

class NumericOption: BaseOption {
  enum Constraint {
    case range(ClosedRange<Double>), quantRange(StrideThrough<Double>), list([Double])
  }

  //MARK: Properties
  let size: Int
  let constraint: Constraint?
  var value = [0.0]

  //MARK: Lifecycle
  override init(from descriptor: SANE_Option_Descriptor, at index: SANE_Int, of device: Device) {
    size = Int(descriptor.size)/MemoryLayout<SANE_Fixed>.stride
    switch descriptor.constraint_type {
    case SANE_CONSTRAINT_NONE:
      constraint = nil
    case SANE_CONSTRAINT_RANGE:
      let range = descriptor.constraint.range.pointee
      let (min, max, quant) = (range.min.unfixed(), range.max.unfixed(), range.quant.unfixed())
      if range.quant == 0 {
        constraint = .range(min ... max)
      } else {
        constraint = .quantRange(stride(from: min, through: max, by: quant))
      }
    case SANE_CONSTRAINT_WORD_LIST:
      guard let ptr = descriptor.constraint.word_list else {
        constraint = nil
        break
      }
      constraint = .list([SANE_Word](UnsafeBufferPointer(start: ptr, count: Int(ptr.pointee))).dropFirst().map({$0.unfixed()}))
    default:
      constraint = nil
    }
    super.init(from: descriptor, at: index, of: device)
  }
}

extension NumericOption: Changeable {
  func fromSane(_ saneValue: [SANE_Word]) -> [Double] {
    return saneValue.map({$0.unfixed()})
  }
  func toSane(_ value: [Double]) -> [SANE_Word] {
    return value.map({$0.fixed()})
  }
  public func getValue() throws -> [Double] {
    try cap.canRead()
    var saneValue = [SANE_Word](repeating: 0, count: size)
    try device?.getValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
  public func setValue(_ value: [Double]) throws -> [Double] {
    guard value.count == size else {
      throw OptionError.invalid
    }
    try cap.canWrite()
    var saneValue = toSane(value)
    try device?.setValue(at: index, to: &saneValue)
    return fromSane(saneValue)
  }
}

/// SANE uses fixed point numbers with a 16 bit shift for decimal numbers
fileprivate let shift = Double(0b1 << 16)

extension Int32 {
  /**
    Converts a SANE fixed point number into a floating point number

    - parameter shift: The shift value which `self` is divided by, defaults to 2^16
    - returns: `self` as a floating point number
  */
  public func unfixed(by shift: Double = shift) -> Double {
    return Double(self)/shift
  }
}

extension Double {
  /**
    Converts a floating point number into a SANE fixed point number

    - parameter shift: The shift value which `self` is multiplied by, defaults to 2^16
    - returns: `self` as a SANE compatible fixed point number
  */
 public func fixed(by shift: Double = shift) -> Int32 {
    return Int32(self*shift)
  }
}

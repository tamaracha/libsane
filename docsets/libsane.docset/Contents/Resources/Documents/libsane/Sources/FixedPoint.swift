import Clibsane

/// SANE uses fixed point numbers with a 16 bit shift for decimal numbers
fileprivate let shift = Double(0b1 << SANE_FIXED_SCALE_SHIFT)

extension SANE_Fixed {
  /**
    Converts a SANE fixed point number into a floating point number

    - parameter shift: The shift value which `self` is divided by, defaults to 2^16
    - returns: `self` as a floating point number
  */
  func unfixed(by shift: Double = shift) -> Double {
    return Double(self)/shift
  }
}

extension Double {
  /**
    Converts a floating point number into a SANE fixed point number

    - parameter shift: The shift value which `self` is multiplied by, defaults to 2^16
    - returns: `self` as a SANE compatible fixed point number
  */
 func fixed(by shift: Double = shift) -> SANE_Fixed {
    return SANE_Fixed(self*shift)
  }
}

fileprivate let shift = Double(0b1 << 16)

extension Int32 {
  func unfixed(by shift: Double = shift) -> Double {
    return Double(self)/shift
  }
}

extension Double {
  func fixed(by shift: Double = shift) -> Int32 {
    return Int32(self*shift)
  }
}

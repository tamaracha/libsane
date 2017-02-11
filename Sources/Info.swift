/// An additional information bitset which is returned after setting a device option. It is implemented as a OptionSet for better swift integration.
struct Info: OptionSet {
  let rawValue: Int
  /// The given value couldn't be set exactly, but the nearest aproximate value is used
  static let inexact = Info(rawValue: 1 << 0)
  /// The option descriptors may have changed
  static let reloadOptions = Info(rawValue: 1 << 1)
  /// the device parameters may have changed.
  static let reloadParams = Info(rawValue: 1 << 2)
}

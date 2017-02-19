import Clibsane

/**
 An additional information bitset which is returned after setting a device option. It is implemented as a OptionSet for better swift integration.

 - seealso: http://sane.alioth.debian.org/html/doc012.html
 */

struct Info: OptionSet {
  let rawValue: Int32
  /// The given value couldn't be set exactly, but the nearest aproximate value is used
  static let inexact = Info(rawValue: SANE_INFO_INEXACT)
  /// The option descriptors may have changed
  static let reloadOptions = Info(rawValue: SANE_INFO_RELOAD_OPTIONS)
  /// the device parameters may have changed.
  static let reloadParams = Info(rawValue: SANE_INFO_RELOAD_PARAMS)
}

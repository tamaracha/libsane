struct Info: OptionSet {
  let rawValue: Int
  static let inexact = Info(rawValue: 1 << 0)
  static let reloadOptions = Info(rawValue: 1 << 1)
  static let reloadParams = Info(rawValue: 1 << 2)
}

/// This represents the version of the SANE api. It consists of major, minor and build number.
public struct Version {
  let major: Int, minor: Int, build: Int

  ///  SANE stores its version info in an Int32 which is decomposed here into major (first byte), minor (second byte), and build (remaining bytes).
  init(_ n: Int32) {
    major = Int((n >> 24) & 0xff)
    minor = Int((n >> 16) & 0xff)
    build = Int((n >> 0) & 0xffff)
  }
}

extension Version: CustomStringConvertible {
  /// Display the version as a version string
  public var description: String {
    return "\(major).\(minor).\(build)"
  }
}

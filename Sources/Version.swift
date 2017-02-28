import Clibsane

/// This represents the version returned by the SANE api. It consists of major, minor and build number.
public struct Version {
  let major: Int, minor: Int, build: Int

  ///  SANE stores its version info in an SANE_Int which is decomposed here into major (first byte), minor (second byte), and build (remaining bytes).
  init(_ n: SANE_Int) {
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

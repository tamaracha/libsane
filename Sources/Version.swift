struct Version {
  let major: Int, minor: Int, build: Int
  init(_ saneValue: Int32) {
    major = Int((saneValue >> 24) & 0xff)
    minor = Int((saneValue >> 16) & 0xff)
    build = Int((saneValue >> 0) & 0xffff)
  }
}

extension Version: CustomStringConvertible {
  var description: String {
    return "\(major).\(minor).\(build)"
  }
}

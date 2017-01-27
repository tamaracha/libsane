struct SaneVersion {
  let major: Int, minor: Int, build: Int
  init(major: Int, minor: Int, build: Int) {
    self.major = major
    self.minor = minor
    self.build = build
  }
  init(_ saneValue: Int32) {
    self.init(
      major: Int((saneValue >> 24) & 0xff),
      minor: Int((saneValue >> 16) & 0xff),
      build: Int((saneValue >> 0) & 0xffff)
    )
  }
}

extension SaneVersion: CustomStringConvertible {
  var description: String {
    return "\(major).\(minor).\(build)"
  }
}

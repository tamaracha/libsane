import Clibsane

public struct Parameters {
  public enum Frame {
    case gray, rgb, red, green, blue
    init?(_ saneValue: SANE_Frame) {
      switch saneValue {
      case SANE_FRAME_GRAY: self = .gray
      case SANE_FRAME_RGB: self = .rgb
      case SANE_FRAME_RED: self = .red
      case SANE_FRAME_GREEN: self = .green
      case SANE_FRAME_BLUE: self = .blue
      default: return nil
      }
    }
  }

  public let format: Frame
  public let lastFrame: Bool
  public let bytesPerLine: Int
  public let pixelsPerLine: Int
  public let lines: Int
  public let depth: Int
  public var bytesTotal: Int? {
    return lines != -1 ? lines*bytesPerLine : nil
  }
  public var bytesPerSample: Int {
    return (depth <= 8) ? 1 : 2
  }

  init(_ saneValue: SANE_Parameters) {
    format = Frame(saneValue.format)!
    lastFrame = saneValue.last_frame == SANE_TRUE
    bytesPerLine = Int(saneValue.bytes_per_line)
    pixelsPerLine = Int(saneValue.pixels_per_line)
    lines = Int(saneValue.lines)
    depth = Int(saneValue.depth)
  }
}

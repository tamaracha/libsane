import Clibsane

/**
  This struct contains scan parameters. These are used to interpret scan data properly.
 */
public struct Parameters {
  /**
    The format in which an image frame can be encoded

   -  seealso: http://sane.alioth.debian.org/html/doc008.html#s3.2
   */
  public enum FrameFormat {
    /// Band covering human visual range.
    case gray
    /// Pixel-interleaved red/green/blue bands.
    case rgb
    /// Red band of a red/green/blue image.
    case red
    /// Green band of a red/green/blue image.
    case green
    /// Blue band of a red/green/blue image.
    case blue
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

  /// The format of the next frame to be returned
  public let format: FrameFormat
  /// Indicates if the current frame or the next to be acquired is the last frame of a multi-frame image
  public let lastFrame: Bool
  /// The number of lines which an image consists of (can be unknown)
  public let lines: Int?
  /// How many bytes make up a line
  public let bytesPerLine: Int
  /// How many pixels make up a line
  public let pixelsPerLine: Int
  /// Number of bits per sample
  public let depth: Int
  /// The total number of bytes, is nil if lines is nil
  public var bytesTotal: Int? {
    if let lines = lines {
      return lines*bytesPerLine
    }
    return nil
  }
  /// Number of bytes per sample, taking care of depth not being 8 or 16
  public var bytesPerSample: Int {
    return (depth <= 8) ? 1 : 2
  }

  init(_ saneValue: SANE_Parameters) {
    format = FrameFormat(saneValue.format)!
    lastFrame = saneValue.last_frame == SANE_TRUE
    bytesPerLine = Int(saneValue.bytes_per_line)
    pixelsPerLine = Int(saneValue.pixels_per_line)
    lines = saneValue.lines != -1 ? Int(saneValue.lines) : nil
    depth = Int(saneValue.depth)
  }
}

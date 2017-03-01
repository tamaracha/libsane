/// An option with no value, but setting it causes an action
public class ButtonOption: BaseOption, Pressable {
  func press() throws {
    try cap.canWrite()
    var saneValue = 0
    try device?.setValue(at: index, to: &saneValue)
  }
}

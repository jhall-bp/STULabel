import STULabelSwift

public enum STULabelConsumer {
  @MainActor
  public static func makeLabel() -> STULabel {
    let label = STULabel()
    _ = label.textFrame
    return label
  }
}

/// Represents a range of text for highlighting search results.
///
/// Used to mark portions of text that match a search query.
class TextRange {
  /// The starting index of the range (inclusive).
  final int start;

  /// The ending index of the range (exclusive).
  final int end;

  TextRange(this.start, this.end);

  /// Returns the length of this text range.
  int get length => end - start;

  /// Checks if this range is valid (start < end).
  bool get isValid => start < end && start >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => 'TextRange($start, $end)';
}

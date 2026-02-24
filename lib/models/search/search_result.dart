import '../chat_model.dart';
import 'text_range.dart';

/// Represents a search result containing a message that matches a search query.
///
/// Includes information about the message, its location in the chat,
/// and the ranges of text that should be highlighted.
class SearchResult {
  /// The message that matches the search query.
  final MessageModel message;

  /// The ID of the chat containing this message.
  final String chatId;

  /// The position of this message in the message list (0-based index).
  final int matchIndex;

  /// List of text ranges within the message that should be highlighted.
  ///
  /// These ranges correspond to the portions of the message text
  /// that match the search query.
  final List<TextRange> highlightRanges;

  SearchResult({
    required this.message,
    required this.chatId,
    required this.matchIndex,
    required this.highlightRanges,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          message.id == other.message.id &&
          chatId == other.chatId &&
          matchIndex == other.matchIndex;

  @override
  int get hashCode =>
      message.id.hashCode ^ chatId.hashCode ^ matchIndex.hashCode;

  @override
  String toString() =>
      'SearchResult(messageId: ${message.id}, chatId: $chatId, matchIndex: $matchIndex, highlights: ${highlightRanges.length})';
}

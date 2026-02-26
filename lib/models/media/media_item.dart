import 'media_type.dart';

/// Represents a media item shared in a conversation
class MediaItem {
  /// Unique identifier for the media item
  final String id;
  
  /// Type of media (photo, video, document, link, voice)
  final MediaType type;
  
  /// URL to access the media
  final String url;
  
  /// Optional thumbnail URL (typically for videos)
  final String? thumbnailUrl;
  
  /// Optional file name (typically for documents)
  final String? fileName;
  
  /// Optional file size in bytes
  final int? fileSize;
  
  /// Optional duration in seconds (for video/voice)
  final int? duration;
  
  /// Timestamp when the media was shared
  final DateTime timestamp;
  
  /// ID of the user who sent the media
  final String senderId;
  
  /// Name of the user who sent the media
  final String senderName;
  
  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    this.duration,
    required this.timestamp,
    required this.senderId,
    required this.senderName,
  });
  
  /// Returns formatted file size (e.g., "1.5 MB", "256 KB")
  String get formattedSize {
    if (fileSize == null) return '';
    
    final bytes = fileSize!;
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }
  
  /// Returns formatted duration (e.g., "1:23", "12:45", "1:02:30")
  String get formattedDuration {
    if (duration == null) return '';
    
    final seconds = duration!;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// Creates a MediaItem from JSON
  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.photo,
      ),
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      duration: json['duration'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
    );
  }

  /// Converts this MediaItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'duration': duration,
      'timestamp': timestamp.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
    };
  }
}

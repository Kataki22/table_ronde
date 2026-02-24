import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/custom_sticker_model.dart';

/// Service to manage custom stickers - loading, saving, editing, deleting
class StickerManager {
  static final StickerManager _instance = StickerManager._internal();
  factory StickerManager() => _instance;
  StickerManager._internal();

  List<CustomStickerModel> _customStickers = [];
  bool _isInitialized = false;

  List<CustomStickerModel> get customStickers =>
      List.unmodifiable(_customStickers);

  /// Initialize the sticker manager - load stickers from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadStickers();
    _isInitialized = true;
  }

  /// Get the directory where stickers are stored
  Future<Directory> _getStickersDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final stickersDir = Directory('${appDir.path}/stickers');

    if (!await stickersDir.exists()) {
      await stickersDir.create(recursive: true);
    }

    return stickersDir;
  }

  /// Get the metadata file
  Future<File> _getMetadataFile() async {
    final stickersDir = await _getStickersDirectory();
    return File('${stickersDir.path}/metadata.json');
  }

  /// Load all stickers from storage
  Future<void> _loadStickers() async {
    try {
      final metadataFile = await _getMetadataFile();

      if (!await metadataFile.exists()) {
        _customStickers = [];
        return;
      }

      final jsonString = await metadataFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      _customStickers = jsonList
          .map((json) => CustomStickerModel.fromJson(json))
          .where((sticker) => File(sticker.filePath)
              .existsSync()) // Only load stickers that still exist
          .toList();
    } catch (e) {
      print('Error loading stickers: $e');
      _customStickers = [];
    }
  }

  /// Save metadata to storage
  Future<void> _saveMetadata() async {
    try {
      final metadataFile = await _getMetadataFile();
      final jsonList = _customStickers.map((s) => s.toJson()).toList();
      await metadataFile.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving sticker metadata: $e');
    }
  }

  /// Add a new sticker
  Future<CustomStickerModel> addSticker({
    required File imageFile,
    required String name,
    String? description,
    String category = 'Mes stickers',
  }) async {
    await initialize();

    final stickersDir = await _getStickersDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last;
    final newFileName = 'sticker_$timestamp.$extension';
    final newPath = '${stickersDir.path}/$newFileName';

    // Copy the file to stickers directory
    await imageFile.copy(newPath);

    // Get file info
    final fileStats = await File(newPath).stat();

    // Create sticker model
    final sticker = CustomStickerModel(
      id: 'custom_$timestamp',
      filePath: newPath,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      category: category,
      fileSize: fileStats.size,
    );

    _customStickers.insert(0, sticker); // Add to beginning
    await _saveMetadata();

    return sticker;
  }

  /// Update an existing sticker's metadata
  Future<void> updateSticker(CustomStickerModel updatedSticker) async {
    await initialize();

    final index = _customStickers.indexWhere((s) => s.id == updatedSticker.id);
    if (index != -1) {
      _customStickers[index] = updatedSticker;
      await _saveMetadata();
    }
  }

  /// Delete a sticker
  Future<bool> deleteSticker(String stickerId) async {
    await initialize();

    final sticker = _customStickers.firstWhere(
      (s) => s.id == stickerId,
      orElse: () => throw Exception('Sticker not found'),
    );

    try {
      // Delete the file
      final file = File(sticker.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from list
      _customStickers.removeWhere((s) => s.id == stickerId);
      await _saveMetadata();

      return true;
    } catch (e) {
      print('Error deleting sticker: $e');
      return false;
    }
  }

  /// Get stickers by category
  List<CustomStickerModel> getStickersByCategory(String category) {
    return _customStickers.where((s) => s.category == category).toList();
  }

  /// Get all categories
  Set<String> getCategories() {
    return _customStickers.map((s) => s.category).toSet();
  }

  /// Clear all custom stickers (for testing/reset)
  Future<void> clearAll() async {
    await initialize();

    // Delete all files
    for (final sticker in _customStickers) {
      final file = File(sticker.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    _customStickers.clear();
    await _saveMetadata();
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'dart:typed_data';
import '../models/scan_history.dart';

class HistoryService {
  static const String _boxName = 'scan_history';
  static Box<ScanHistory>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanHistoryAdapter());
    _box = await Hive.openBox<ScanHistory>(_boxName);
  }

  static Box<ScanHistory> get box {
    if (_box == null) {
      throw Exception('HistoryService not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<void> addScanResult({
    required String type,
    required String content,
    String? format,
    Uint8List? imageData,
  }) async {
    final history = ScanHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: content,
      timestamp: DateTime.now(),
      format: format,
      imageData: imageData,
    );

    await box.add(history);

    // Keep only last 10 items
    if (box.length > 10) {
      final keys = box.keys.toList();
      keys.sort();
      // Remove oldest items
      for (int i = 0; i < box.length - 10; i++) {
        await box.delete(keys[i]);
      }
    }
  }

  static List<ScanHistory> getHistory() {
    final history = box.values.toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  static Future<void> deleteHistory(String id) async {
    try {
      // Find the key with matching id
      dynamic keyToDelete;
      for (final key in box.keys) {
        final item = box.get(key);
        if (item?.id == id) {
          keyToDelete = key;
          break;
        }
      }

      // Delete if found
      if (keyToDelete != null) {
        await box.delete(keyToDelete);
      }
    } catch (e) {
      throw Exception('Failed to delete history item: $e');
    }
  }

  static Future<void> clearAllHistory() async {
    await box.clear();
  }
}

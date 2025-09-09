import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'scan_history.g.dart';

@HiveType(typeId: 0)
class ScanHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'QR' or 'Barcode'

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? format; // QR type: email, url, text, etc.

  @HiveField(5)
  Uint8List? imageData; // QR/Barcode image as bytes

  ScanHistory({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.format,
    this.imageData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'format': format,
      'hasImage': imageData != null,
    };
  }

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      format: json['format'],
      // Note: imageData is not included in JSON serialization for size reasons
    );
  }
}

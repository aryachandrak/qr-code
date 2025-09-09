import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRBarcodeGenerator {
  /// Generate QR code image as bytes
  static Future<Uint8List?> generateQRImage(String data) async {
    try {
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: false,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final size = 300.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      qrPainter.paint(canvas, Size(size, size));

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error generating QR image: $e');
      return null;
    }
  }

  /// Generate image from RepaintBoundary (for scanned QR/barcodes)
  static Future<Uint8List?> captureFromWidget(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      if (boundary.debugNeedsPaint) {
        // Wait for the widget to be painted
        await Future.delayed(Duration(milliseconds: 20));
        return captureFromWidget(key);
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  /// Determine if content is QR or Barcode based on format
  static String getType(String? format) {
    if (format == null) return 'QR';

    final barcodeFormats = [
      'code39',
      'code_39',
      'code93',
      'code_93',
      'code128',
      'code_128',
      'ean13',
      'ean_13',
      'ean8',
      'ean_8',
      'upca',
      'upc_a',
      'upce',
      'upc_e'
    ];

    return barcodeFormats.contains(format.toLowerCase()) ? 'Barcode' : 'QR';
  }
}

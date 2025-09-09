import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

class QRDownloadUtil {
  static Future<void> downloadQRCode(
      BuildContext context, GlobalKey qrKey) async {
    try {
      bool hasPermission = false;
      if (await Permission.photos.isGranted) {
        hasPermission = true;
      } else {
        var photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          hasPermission = true;
        }
      }
      if (!hasPermission) {
        var storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          hasPermission = true;
        }
      }
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Storage permission is required to download QR code')),
        );
        return;
      }

      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          paint);
      final ui.Image qrImage = await ui
          .instantiateImageCodec(pngBytes)
          .then((codec) => codec.getNextFrame())
          .then((frame) => frame.image);
      canvas.drawImage(qrImage, Offset.zero, Paint());
      final ui.Picture picture = recorder.endRecording();
      final ui.Image jpgImage =
          await picture.toImage(image.width, image.height);
      final ByteData? jpgByteData =
          await jpgImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List imageBytes = jpgByteData!.buffer.asUint8List();

      await Gal.putImageBytes(
        imageBytes,
        name: "qr_code_${DateTime.now().millisecondsSinceEpoch}",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading QR code: $e')),
      );
    }
  }
}

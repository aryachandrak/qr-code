import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class Code93BarcodeScreen extends StatefulWidget {
  const Code93BarcodeScreen({super.key});

  @override
  State<Code93BarcodeScreen> createState() => _Code93BarcodeScreenState();
}

class _Code93BarcodeScreenState extends State<Code93BarcodeScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _barcodeKey = GlobalKey();
  String barcodeData = '';
  bool showBarcode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code 93 Barcode'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Code 93 Barcode',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Code 93 adalah format barcode yang lebih efisien dari Code 39. Mendukung huruf kapital (A-Z), angka (0-9), dan simbol khusus. Cocok untuk aplikasi yang memerlukan kepadatan data tinggi.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Section
              Text(
                'Masukkan Data untuk Code 93:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                maxLines: 2,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Contoh: ABC123, HELLO WORLD, 1234567890',
                  labelText: 'Data Content (huruf kapital dan angka)',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Z0-9\s\-\.\$\/\+%]')),
                ],
                onChanged: (value) {
                  setState(() {
                    showBarcode = false;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Generate Button
              ElevatedButton(
                onPressed: _generateBarcode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Generate Code 93 Barcode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // Barcode Display
              if (showBarcode && barcodeData.isNotEmpty) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Code 93 Barcode:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        RepaintBoundary(
                          key: _barcodeKey,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _buildBarcodeWidget(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Data: $barcodeData',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareBarcode(),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _downloadBarcode,
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeWidget() {
    try {
      return BarcodeWidget(
        barcode: Barcode.code93(),
        data: barcodeData,
        width: 300,
        height: 100,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } catch (e) {
      // Show error message in UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri tidak valid untuk Code 93 barcode'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Entri Tidak Valid',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Code 93 hanya mendukung huruf kapital, angka, dan simbol tertentu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  void _generateBarcode() {
    String text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan data untuk barcode'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate Code 93 characters
    if (!RegExp(r'^[A-Z0-9\s\-\.\$\/\+%]+$').hasMatch(text.toUpperCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Code 93 hanya mendukung huruf kapital, angka, dan beberapa simbol khusus'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      barcodeData = text.toUpperCase();
      showBarcode = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code 93 barcode berhasil dibuat!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareBarcode() {
    if (barcodeData.isNotEmpty) {
      Share.share(
        'Code 93 Barcode: $barcodeData',
        subject: 'Generated Code 93 Barcode',
      );
    }
  }

  Future<void> _downloadBarcode() async {
    try {
      // Capture the barcode as image
      RenderRepaintBoundary boundary = _barcodeKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery
      await Gal.putImageBytes(pngBytes, album: "QR & Barcode App");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barcode berhasil disimpan ke galeri!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menyimpan barcode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

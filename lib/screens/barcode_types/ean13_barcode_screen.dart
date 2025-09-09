import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class EAN13BarcodeScreen extends StatefulWidget {
  const EAN13BarcodeScreen({super.key});

  @override
  State<EAN13BarcodeScreen> createState() => _EAN13BarcodeScreenState();
}

class _EAN13BarcodeScreenState extends State<EAN13BarcodeScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _barcodeKey = GlobalKey();
  String barcodeData = '';
  bool showBarcode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EAN-13 Barcode'),
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
                            'EAN-13 Barcode',
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
                        'EAN-13 adalah barcode produk Eropa. Masukkan 12 digit angka, dan digit checksum akan dihitung otomatis untuk menghasilkan barcode 13 digit.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Section
              Text(
                'Masukkan 12 Digit untuk EAN-13:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Contoh: 123456789012',
                  labelText: '12 Digit Number (checksum dihitung otomatis)',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  helperText:
                      'Masukkan tepat 12 digit angka, digit ke-13 akan dihitung otomatis',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                onChanged: (value) {
                  setState(() {
                    showBarcode = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_textController.text.length == 12)
                    ? _generateBarcode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Generate EAN-13 Barcode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // Generated Barcode Section
              if (showBarcode) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Generated EAN-13',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // Barcode Widget
                        RepaintBoundary(
                          key: _barcodeKey,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: _buildBarcodeWidget(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Data Display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EAN-13 Code:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                barcodeData,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
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
        barcode: Barcode.ean13(),
        data: barcodeData,
        width: 200,
        height: 80,
        style: const TextStyle(fontSize: 12),
      );
    } catch (e) {
      // Show error message in UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri tidak valid untuk EAN-13 barcode'),
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
              'EAN-13 memerlukan 12 digit angka yang valid',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
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
    );
  }

  void _generateBarcode() {
    if (_textController.text.length == 12) {
      String twelveDigits = _textController.text;
      String checksum = _calculateEAN13Checksum(twelveDigits);
      String fullEAN13 = twelveDigits + checksum;

      setState(() {
        barcodeData = fullEAN13;
        showBarcode = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('EAN-13 berhasil dibuat: $fullEAN13 (checksum: $checksum)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _calculateEAN13Checksum(String twelveDigits) {
    int sum = 0;

    // EAN-13 checksum calculation
    // Multiply digits at odd positions (1st, 3rd, 5th, etc.) by 1
    // Multiply digits at even positions (2nd, 4th, 6th, etc.) by 3
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(twelveDigits[i]);
      if (i % 2 == 0) {
        sum += digit * 1; // positions 1, 3, 5, etc. (0-indexed: 0, 2, 4, etc.)
      } else {
        sum += digit * 3; // positions 2, 4, 6, etc. (0-indexed: 1, 3, 5, etc.)
      }
    }

    int checksum = (10 - (sum % 10)) % 10;
    return checksum.toString();
  }

  void _shareBarcode() {
    Share.share(
      barcodeData,
      subject: 'EAN-13 Barcode Generated',
    );
  }

  Future<void> _downloadBarcode() async {
    try {
      // Capture the barcode widget as image
      RenderRepaintBoundary boundary = _barcodeKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery
      await Gal.putImageBytes(pngBytes,
          name: 'EAN13_${DateTime.now().millisecondsSinceEpoch}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode berhasil disimpan ke galeri'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barcode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

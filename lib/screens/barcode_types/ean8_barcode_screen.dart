import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;

class EAN8BarcodeScreen extends StatefulWidget {
  const EAN8BarcodeScreen({super.key});

  @override
  State<EAN8BarcodeScreen> createState() => _EAN8BarcodeScreenState();
}

class _EAN8BarcodeScreenState extends State<EAN8BarcodeScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _barcodeKey = GlobalKey();
  String barcodeData = '';
  bool showBarcode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EAN-8 Barcode'),
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
                            'EAN-8 Barcode',
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
                        'EAN-8 adalah format barcode untuk produk kecil. Masukkan 7 digit angka, dan digit checksum akan dihitung otomatis untuk menghasilkan barcode 8 digit.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Section
              Text(
                'Masukkan 7 Digit untuk EAN-8:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                keyboardType: TextInputType.number,
                maxLength: 7,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Contoh: 1234567',
                  labelText: '7 Digit Number (checksum dihitung otomatis)',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  helperText:
                      'Masukkan tepat 7 digit angka, digit ke-8 akan dihitung otomatis',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                onChanged: (value) {
                  setState(() {
                    showBarcode = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: (_textController.text.length == 7)
                    ? _generateBarcode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Generate EAN-8 Barcode',
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
                          'Generated EAN-8',
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
                                'EAN-8 Code:',
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
        barcode: Barcode.ean8(),
        data: barcodeData,
        width: 250,
        height: 80,
        style: const TextStyle(fontSize: 12),
      );
    } catch (e) {
      // Show error message in UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri tidak valid untuk EAN-8 barcode'),
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
              'EAN-8 memerlukan 7 digit angka yang valid',
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
            onPressed: _shareBarcode,
            icon: const Icon(Icons.share),
            label: const Text('Bagikan'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadBarcode,
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _generateBarcode() {
    if (_textController.text.length == 7) {
      String sevenDigits = _textController.text;
      String checksum = _calculateEAN8Checksum(sevenDigits);
      String fullEAN8 = sevenDigits + checksum;

      setState(() {
        barcodeData = fullEAN8;
        showBarcode = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('EAN-8 berhasil dibuat: $fullEAN8 (checksum: $checksum)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _calculateEAN8Checksum(String sevenDigits) {
    int sum = 0;

    for (int i = 0; i < 7; i++) {
      int digit = int.parse(sevenDigits[i]);
      if (i % 2 == 0) {
        sum += digit * 3; 
      } else {
        sum += digit * 1; 
      }
    }

    int checksum = (10 - (sum % 10)) % 10;
    return checksum.toString();
  }

  void _shareBarcode() {
    Share.share(
      barcodeData,
      subject: 'EAN-8 Barcode Generated',
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
          name: 'EAN8_${DateTime.now().millisecondsSinceEpoch}');

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

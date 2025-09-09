import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'dart:ui' as ui;

class UPCEBarcodeScreen extends StatefulWidget {
  const UPCEBarcodeScreen({super.key});

  @override
  State<UPCEBarcodeScreen> createState() => _UPCEBarcodeScreenState();
}

class _UPCEBarcodeScreenState extends State<UPCEBarcodeScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _barcodeKey = GlobalKey();
  String barcodeData = '';
  bool showBarcode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPC-E Barcode'),
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
                            'UPC-E Barcode',
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
                        'UPC-E adalah versi kompak dari UPC-A yang menggunakan 8 digit. Format ini cocok untuk produk kecil dengan space terbatas untuk barcode.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Input Section
              Text(
                'Masukkan 6-7 Digit untuk UPC-E:',
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
                  hintText: 'Contoh: 123456 atau 1234567',
                  labelText: '6-7 Digit Number',
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  helperText: 'Masukkan 6-7 digit angka untuk UPC-E',
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
                onPressed: (_textController.text.length >= 6 &&
                        _textController.text.length <= 7)
                    ? _generateBarcode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Generate UPC-E Barcode',
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
                          'Generated UPC-E',
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
                                'UPC-E Code:',
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
        barcode: Barcode.upcE(),
        data: barcodeData,
        width: 300,
        height: 80,
        style: const TextStyle(fontSize: 12),
      );
    } catch (e) {
      // Show error message in UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri tidak valid untuk UPC-E barcode'),
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
              'UPC-E memerlukan 6-7 digit angka yang valid',
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
    if (_textController.text.length >= 6 && _textController.text.length <= 7) {
      setState(() {
        barcodeData = _textController.text;
        showBarcode = true;
      });
    }
  }

  void _shareBarcode() {
    Share.share(
      barcodeData,
      subject: 'UPC-E Barcode Generated',
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
          name: 'UPCE_${DateTime.now().millisecondsSinceEpoch}');

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

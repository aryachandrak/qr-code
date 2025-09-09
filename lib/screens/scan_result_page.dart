import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../utils/qr_detector.dart';
import '../utils/qr_barcode_generator.dart';
import '../services/history_service.dart';

class ScanResultPage extends StatefulWidget {
  final String type;
  final String content;
  final DateTime timestamp;
  final bool isFromHistory; // New parameter to indicate if opened from history

  const ScanResultPage({
    super.key,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isFromHistory = false, // Default false for new scans
  });

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  final GlobalKey _qrKey = GlobalKey();
  bool _savedToHistory = false;

  @override
  void initState() {
    super.initState();
    // Only auto-save to history if this is NOT from history (i.e., it's a new scan)
    if (!widget.isFromHistory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _saveToHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil ${widget.type}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.type == 'QR Code' ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.type,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timestamp
            Text(
              'Discan pada: ${DateFormat('dd MMM yyyy, HH:mm').format(widget.timestamp)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // QR Code Display (for QR codes only)
            if (widget.type == 'QR Code') ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'QR Code:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: QrImageView(
                            data: widget.content,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Barcode Display (for barcodes only)
            if (widget.type != 'QR Code') ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${widget.type}:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: _buildBarcodeWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Content Card
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
                          widget.type == 'QR Code'
                              ? Icons.qr_code
                              : Icons.barcode_reader,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Konten:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SelectableText(
                        widget.content,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Salin ke Clipboard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareContent(),
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // QR Code Specific Actions (for QR Code only)
                if (widget.type == 'QR Code') ...[
                  const SizedBox(height: 12),
                  _buildQRSpecificActionButton(context),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // Additional Info for URLs
            if (_isUrl(widget.content)) ...[
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.language, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Link Terdeteksi',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(context),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Buka Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konten berhasil disalin ke clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareContent() {
    Share.share(
      widget.content,
      subject: 'Hasil Scan ${widget.type}',
    );
  }

  Future<void> _saveToHistory() async {
    if (_savedToHistory) return;

    try {
      // Generate image data based on type
      Uint8List? imageData;
      if (widget.type == 'QR Code') {
        imageData = await QRBarcodeGenerator.generateQRImage(widget.content);
      } else {
        // For barcodes, capture from the displayed barcode widget
        imageData = await QRBarcodeGenerator.captureFromWidget(_qrKey);
      }

      await HistoryService.addScanResult(
        type: widget.type,
        content: widget.content,
        format: widget.type == 'QR Code' ? 'QR' : 'BARCODE',
        imageData: imageData,
      );

      setState(() {
        _savedToHistory = true;
      });
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  Widget _buildQRSpecificActionButton(BuildContext context) {
    final qrType = QRCodeDetector.detectQRType(widget.content);

    // Only show specific actions for supported QR types
    if (qrType == QRCodeType.text || qrType == QRCodeType.url) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleQRAction(context, qrType),
        icon: Icon(_getActionIcon(qrType), color: Colors.white,),
        label: Text(_getActionText(qrType)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBarcodeWidget() {
    try {
      // Determine barcode type and create appropriate widget
      Barcode barcodeType;

      switch (widget.type) {
        case 'Code 39':
          barcodeType = Barcode.code39();
          break;
        case 'Code 93':
          barcodeType = Barcode.code93();
          break;
        case 'Code 128':
          barcodeType = Barcode.code128();
          break;
        case 'EAN-8':
          barcodeType = Barcode.ean8();
          break;
        case 'EAN-13':
          barcodeType = Barcode.ean13();
          break;
        case 'UPC-A':
          barcodeType = Barcode.upcA();
          break;
        case 'UPC-E':
          barcodeType = Barcode.upcE();
          break;
        default:
          // Default to Code 128 for generic barcodes
          barcodeType = Barcode.code128();
      }

      return BarcodeWidget(
        barcode: barcodeType,
        data: widget.content,
        width: 300,
        height: 100,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    } catch (e) {
      // If barcode generation fails, show error message
      return Container(
        width: 300,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Cannot generate ${widget.type}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  IconData _getActionIcon(QRCodeType type) {
    switch (type) {
      case QRCodeType.email:
        return Icons.mail_outline;
      case QRCodeType.contact:
        return Icons.person_add;
      case QRCodeType.phone:
        return Icons.call;
      case QRCodeType.location:
        return Icons.map;
      case QRCodeType.wifi:
        return Icons.wifi_password;
      case QRCodeType.calendar:
        return Icons.event_available;
      default:
        return Icons.open_in_new;
    }
  }

  String _getActionText(QRCodeType type) {
    switch (type) {
      case QRCodeType.email:
        return 'Buka Email';
      case QRCodeType.contact:
        return 'Tambah Kontak';
      case QRCodeType.phone:
        return 'Telepon';
      case QRCodeType.location:
        return 'Buka Maps';
      case QRCodeType.wifi:
        return 'Pengaturan WiFi';
      case QRCodeType.calendar:
        return 'Tambah ke Kalender';
      default:
        return 'Buka';
    }
  }

  Future<void> _handleQRAction(BuildContext context, QRCodeType type) async {
    try {
      await QRCodeDetector.handleQRAction(context, widget.content);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.');
  }

  void _openUrl(BuildContext context) {
    // Show dialog asking user to open in browser
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka Link'),
        content: Text('Buka link ini di browser?\n\n${widget.content}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would use url_launcher package
              _copyToClipboard(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Link disalin ke clipboard. Buka di browser secara manual.'),
                ),
              );
            },
            child: const Text('Salin Link'),
          ),
        ],
      ),
    );
  }
}

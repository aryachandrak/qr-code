import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../utils/qr_download_util.dart';

class URLQRScreen extends StatefulWidget {
  const URLQRScreen({super.key});

  @override
  State<URLQRScreen> createState() => _URLQRScreenState();
}

class _URLQRScreenState extends State<URLQRScreen> {
  final TextEditingController _urlController = TextEditingController();
  String qrData = '';
  final GlobalKey qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _urlController.text = 'https://';
    
    // Add listener to prevent deleting https://
    _urlController.addListener(() {
      if (!_urlController.text.startsWith('https://')) {
        _urlController.text = 'https://';
        _urlController.selection = TextSelection.fromPosition(
          TextPosition(offset: _urlController.text.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL QR Code'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter URL to generate QR Code:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com',
                  labelText: 'Website URL',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  // Prevent user from deleting https://
                  if (!value.startsWith('https://')) {
                    _urlController.text = 'https://';
                    _urlController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _urlController.text.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String url = _urlController.text.trim();
                  if (url.isNotEmpty && url.length > 8) { // More than just 'https://'
                    setState(() {
                      qrData = url;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid URL after https://'),
                      ),
                    );
                  }
                },
                child: const Text('Generate QR Code'),
              ),
              const SizedBox(height: 24),
              if (qrData.isNotEmpty) ...[
                Text(
                  'Generated QR Code:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 77),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: RepaintBoundary(
                      key: qrKey,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URL:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        qrData,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [                    
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _urlController.text = 'https://';
                            qrData = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            QRDownloadUtil.downloadQRCode(context, qrKey),
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
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

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

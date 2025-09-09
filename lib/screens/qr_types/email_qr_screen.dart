import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../utils/qr_download_util.dart';

class EmailQRScreen extends StatefulWidget {
  const EmailQRScreen({super.key});

  @override
  State<EmailQRScreen> createState() => _EmailQRScreenState();
}

class _EmailQRScreenState extends State<EmailQRScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String qrData = '';
  final GlobalKey qrKey = GlobalKey();

  String _generateMailto() {
    String mailto = 'mailto:${_emailController.text}';
    List<String> params = [];

    if (_subjectController.text.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(_subjectController.text)}');
    }

    if (_bodyController.text.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(_bodyController.text)}');
    }

    if (params.isNotEmpty) {
      mailto += '?${params.join('&')}';
    }

    return mailto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email QR Code'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter email information:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email),
                        hintText: 'example@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.subject),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Message Body',
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.trim().isNotEmpty) {
                          setState(() {
                            qrData = _generateMailto();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Email address is required')),
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
                              'Email Information:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('To: ${_emailController.text}'),
                            if (_subjectController.text.isNotEmpty)
                              Text('Subject: ${_subjectController.text}'),
                            if (_bodyController.text.isNotEmpty)
                              Text('Body: ${_bodyController.text}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Scanning this QR code will open email client',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                                  _emailController.clear();
                                  _subjectController.clear();
                                  _bodyController.clear();
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
                              onPressed: () => QRDownloadUtil.downloadQRCode(
                                  context, qrKey),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}

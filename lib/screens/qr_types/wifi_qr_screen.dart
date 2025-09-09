import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../utils/qr_download_util.dart';

class WiFiQRScreen extends StatefulWidget {
  const WiFiQRScreen({super.key});

  @override
  State<WiFiQRScreen> createState() => _WiFiQRScreenState();
}

class _WiFiQRScreenState extends State<WiFiQRScreen> {
  final TextEditingController _networkController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String selectedSecurity = 'WPA';
  bool isPasswordVisible = false;
  String qrData = '';
  final GlobalKey qrKey = GlobalKey();

  String _generateWiFiString() {
    return 'WIFI:T:$selectedSecurity;S:${_networkController.text};P:${_passwordController.text};;';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi QR Code'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter WiFi credentials:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _networkController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Network Name (SSID)',
                  prefixIcon: Icon(Icons.wifi),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSecurity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Security Type',
                  prefixIcon: Icon(Icons.security),
                ),
                items: ['WPA', 'WEP', 'nopass'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'nopass' ? 'No Password' : value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSecurity = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_networkController.text.trim().isNotEmpty) {
                    setState(() {
                      qrData = _generateWiFiString();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Network name is required')),
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
                        'WiFi Information:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Network: ${_networkController.text}'),
                      Text(
                          'Security: ${selectedSecurity == 'nopass' ? 'No Password' : selectedSecurity}'),
                      if (selectedSecurity != 'nopass' &&
                          _passwordController.text.isNotEmpty)
                        Text(
                            'Password: ${'*' * _passwordController.text.length}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Scanning this QR code will connect to WiFi network',
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
                            _networkController.clear();
                            _passwordController.clear();
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
    _networkController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

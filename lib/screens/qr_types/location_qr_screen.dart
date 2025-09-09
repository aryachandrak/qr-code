import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../../utils/qr_download_util.dart';

class LocationQRScreen extends StatefulWidget {
  const LocationQRScreen({super.key});

  @override
  State<LocationQRScreen> createState() => _LocationQRScreenState();
}

class _LocationQRScreenState extends State<LocationQRScreen> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  String qrData = '';
  final GlobalKey qrKey = GlobalKey();

  String _generateGeoUri() {
    return 'geo:${_latitudeController.text},${_longitudeController.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location QR Code'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter location coordinates:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Latitude',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: '-7.9666',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Longitude',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: '112.6326',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_latitudeController.text.trim().isNotEmpty &&
                      _longitudeController.text.trim().isNotEmpty) {
                    setState(() {
                      qrData = _generateGeoUri();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Both latitude and longitude are required')),
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
                        'Location Information:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Latitude: ${_latitudeController.text}'),
                      Text('Longitude: ${_longitudeController.text}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Scanning this QR code will open location in maps',
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
                            _latitudeController.clear();
                            _longitudeController.clear();
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
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}

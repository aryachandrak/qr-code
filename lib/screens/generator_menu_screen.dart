import 'package:flutter/material.dart';
import 'qr_types/text_qr_screen.dart';
import 'qr_types/url_qr_screen.dart';
import 'qr_types/email_qr_screen.dart';
import 'qr_types/phone_qr_screen.dart';
import 'qr_types/contact_qr_screen.dart';
import 'qr_types/wifi_qr_screen.dart';
import 'qr_types/location_qr_screen.dart';
import 'qr_types/calendar_qr_screen.dart';
import 'barcode_types/code39_barcode_screen.dart';
import 'barcode_types/code93_barcode_screen.dart';
import 'barcode_types/code128_barcode_screen.dart';
import 'barcode_types/ean8_barcode_screen.dart';
import 'barcode_types/ean13_barcode_screen.dart';
import 'barcode_types/upca_barcode_screen.dart';
import 'barcode_types/upce_barcode_screen.dart';

class GeneratorMenuScreen extends StatefulWidget {
  const GeneratorMenuScreen({super.key});

  @override
  State<GeneratorMenuScreen> createState() => _GeneratorMenuScreenState();
}

class _GeneratorMenuScreenState extends State<GeneratorMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.qr_code),
              text: 'QR Code',
            ),
            Tab(
              icon: Icon(Icons.barcode_reader),
              text: 'Barcode',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQrCodeMenu(),
          _buildBarcodeMenu(),
        ],
      ),
    );
  }

  Widget _buildQrCodeMenu() {
    final qrTypes = [
      {
        'title': 'Text',
        'subtitle': 'Generate QR code for plain text',
        'icon': Icons.text_fields,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const TextQRScreen(),
      },
      {
        'title': 'URL',
        'subtitle': 'Generate QR code for website links',
        'icon': Icons.link,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const URLQRScreen(),
      },
      {
        'title': 'Email',
        'subtitle': 'Generate QR code for email addresses',
        'icon': Icons.email,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const EmailQRScreen(),
      },
      {
        'title': 'Phone',
        'subtitle': 'Generate QR code for phone numbers',
        'icon': Icons.phone,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const PhoneQRScreen(),
      },
      {
        'title': 'Contact',
        'subtitle': 'Generate QR code for contact information',
        'icon': Icons.contact_page,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const ContactQRScreen(),
      },
      {
        'title': 'WiFi',
        'subtitle': 'Generate QR code for WiFi credentials',
        'icon': Icons.wifi,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const WiFiQRScreen(),
      },
      {
        'title': 'Location',
        'subtitle': 'Generate QR code for GPS coordinates',
        'icon': Icons.location_on,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const LocationQRScreen(),
      },
      {
        'title': 'Calendar',
        'subtitle': 'Generate QR code for calendar events',
        'icon': Icons.calendar_today,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const CalendarQRScreen(),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: qrTypes.length,
      itemBuilder: (context, index) {
        final qrType = qrTypes[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (qrType['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                qrType['icon'] as IconData,
                color: qrType['color'] as Color,
                size: 28,
              ),
            ),
            title: Text(
              qrType['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              qrType['subtitle'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => qrType['screen'] as Widget,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBarcodeMenu() {
    final List<Map<String, dynamic>> barcodeTypes = [
      {
        'title': 'Code 39',
        'subtitle': 'Alphanumeric barcode untuk industri',
        'icon': Icons.inventory,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const Code39BarcodeScreen(),
      },
      {
        'title': 'Code 93',
        'subtitle': 'Barcode efisien dengan kepadatan tinggi',
        'icon': Icons.qr_code_2,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const Code93BarcodeScreen(),
      },
      {
        'title': 'Code 128',
        'subtitle': 'Universal barcode untuk teks dan angka',
        'icon': Icons.barcode_reader,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const Code128BarcodeScreen(),
      },
      {
        'title': 'EAN-8',
        'subtitle': 'Barcode 8 digit untuk produk kecil',
        'icon': Icons.shopping_bag,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const EAN8BarcodeScreen(),
      },
      {
        'title': 'EAN-13',
        'subtitle': 'Barcode 13 digit standar internasional untuk ritel',
        'icon': Icons.shopping_cart,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const EAN13BarcodeScreen(),
      },
      {
        'title': 'UPC-A',
        'subtitle': 'Barcode produk Amerika (12 digit)',
        'icon': Icons.store,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const UPCABarcodeScreen(),
      },
      {
        'title': 'UPC-E',
        'subtitle': 'Versi pendek dari UPC-A untuk kemasan kecil',
        'icon': Icons.receipt,
        'color': Theme.of(context).colorScheme.primary,
        'screen': const UPCEBarcodeScreen(),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: barcodeTypes.length,
      itemBuilder: (context, index) {
        final barcodeType = barcodeTypes[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (barcodeType['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                barcodeType['icon'] as IconData,
                color: barcodeType['color'] as Color,
                size: 28,
              ),
            ),
            title: Text(
              barcodeType['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              barcodeType['subtitle'] as String,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => barcodeType['screen'] as Widget,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

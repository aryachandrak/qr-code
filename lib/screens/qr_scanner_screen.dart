import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'scan_result_page.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late mobile_scanner.MobileScannerController cameraController;
  bool isScanning = true;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cameraController = mobile_scanner.MobileScannerController(
      detectionSpeed: mobile_scanner.DetectionSpeed.normal,
      facing: mobile_scanner.CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
      formats: [
        mobile_scanner.BarcodeFormat.qrCode,
        mobile_scanner.BarcodeFormat.code128,
        mobile_scanner.BarcodeFormat.code39,
        mobile_scanner.BarcodeFormat.code93,
        mobile_scanner.BarcodeFormat.ean13,
        mobile_scanner.BarcodeFormat.ean8,
        mobile_scanner.BarcodeFormat.upcA,
        mobile_scanner.BarcodeFormat.upcE,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Barcode Scanner'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          mobile_scanner.MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status text with icon
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isScanning
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2)
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isScanning
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isScanning
                              ? Icons.qr_code_scanner
                              : Icons.check_circle,
                          color: isScanning
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isScanning
                              ? 'Arahkan kamera ke QR Code atau Barcode'
                              : 'Kode terdeteksi!',
                          style: TextStyle(
                            color: isScanning
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Control buttons in cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      _buildControlButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onPressed: _pickImageFromGallery,
                        color: Colors.purple,
                      ),
                      // Flash button
                      _buildControlButton(
                        icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                        label: 'Flash',
                        onPressed: () async {
                          await cameraController.toggleTorch();
                          setState(() {
                            isFlashOn = !isFlashOn;
                          });
                        },
                        color: isFlashOn ? Colors.amber : Colors.grey,
                        isActive: isFlashOn,
                      ),
                      // Switch camera button
                      _buildControlButton(
                        icon: isFrontCamera
                            ? Icons.camera_front
                            : Icons.camera_rear,
                        label: 'Switch',
                        onPressed: () async {
                          await cameraController.switchCamera();
                          setState(() {
                            isFrontCamera = !isFrontCamera;
                          });
                        },
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _scanQRFromImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _scanQRFromImage(XFile imageFile) async {
    try {
      final mlkit.BarcodeScanner barcodeScanner = mlkit.BarcodeScanner(
        formats: [
          mlkit.BarcodeFormat.qrCode,
          mlkit.BarcodeFormat.code128,
          mlkit.BarcodeFormat.code39,
          mlkit.BarcodeFormat.code93,
          mlkit.BarcodeFormat.ean13,
          mlkit.BarcodeFormat.ean8,
          mlkit.BarcodeFormat.upca,
          mlkit.BarcodeFormat.upce,
        ],
      );

      final mlkit.InputImage inputImage =
          mlkit.InputImage.fromFilePath(imageFile.path);
      final List<mlkit.Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        String? qrContent;

        // Try to get the most complete data
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          qrContent = barcode.rawValue!;
        } else if (barcode.displayValue != null &&
            barcode.displayValue!.isNotEmpty) {
          qrContent = barcode.displayValue!;
        }

        if (qrContent != null && qrContent.isNotEmpty) {
          setState(() {
            isScanning = false;
          });

          // Convert MLKit format to mobile_scanner format
          mobile_scanner.BarcodeFormat? mobileFormat;
          switch (barcode.format) {
            case mlkit.BarcodeFormat.qrCode:
              mobileFormat = mobile_scanner.BarcodeFormat.qrCode;
              break;
            case mlkit.BarcodeFormat.code128:
              mobileFormat = mobile_scanner.BarcodeFormat.code128;
              break;
            case mlkit.BarcodeFormat.code39:
              mobileFormat = mobile_scanner.BarcodeFormat.code39;
              break;
            case mlkit.BarcodeFormat.code93:
              mobileFormat = mobile_scanner.BarcodeFormat.code93;
              break;
            case mlkit.BarcodeFormat.ean13:
              mobileFormat = mobile_scanner.BarcodeFormat.ean13;
              break;
            case mlkit.BarcodeFormat.ean8:
              mobileFormat = mobile_scanner.BarcodeFormat.ean8;
              break;
            case mlkit.BarcodeFormat.upca:
              mobileFormat = mobile_scanner.BarcodeFormat.upcA;
              break;
            case mlkit.BarcodeFormat.upce:
              mobileFormat = mobile_scanner.BarcodeFormat.upcE;
              break;
            default:
              mobileFormat = null;
          }

          _navigateToResult(qrContent, mobileFormat);
        } else {
          _showErrorDialog('No QR code or barcode content found');
        }
      } else {
        _showErrorDialog('No QR code or barcode found in the selected image');
      }

      await barcodeScanner.close();
    } catch (e) {
      _showErrorDialog('Error scanning QR code or barcode: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(mobile_scanner.BarcodeCapture capture) {
    if (!isScanning) return;

    final List<mobile_scanner.Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      // Try multiple approaches to get the complete QR data
      String? qrData;

      // Method 1: Try rawValue first (usually most complete)
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        qrData = barcode.rawValue!;
      }
      // Method 2: Try displayValue as fallback
      else if (barcode.displayValue != null &&
          barcode.displayValue!.isNotEmpty) {
        qrData = barcode.displayValue!;
      }

      // Method 3: For email QR codes, try to reconstruct from email object
      if (barcode.type == mobile_scanner.BarcodeType.email &&
          barcode.email != null) {
        final email = barcode.email!;

        // If we have subject or body, reconstruct the mailto URL
        if ((email.subject != null && email.subject!.isNotEmpty) ||
            (email.body != null && email.body!.isNotEmpty)) {
          String reconstructedEmail = 'mailto:${email.address ?? ''}';

          List<String> queryParams = [];
          if (email.subject != null && email.subject!.isNotEmpty) {
            queryParams.add('subject=${Uri.encodeComponent(email.subject!)}');
          }
          if (email.body != null && email.body!.isNotEmpty) {
            queryParams.add('body=${Uri.encodeComponent(email.body!)}');
          }

          if (queryParams.isNotEmpty) {
            reconstructedEmail += '?${queryParams.join('&')}';
          }

          // Use reconstructed email if it's more complete than raw data
          if (qrData == null || qrData.length < reconstructedEmail.length) {
            qrData = reconstructedEmail;
          }
        }
      }

      // Method 4: Try other specific types
      if (barcode.type == mobile_scanner.BarcodeType.url &&
          barcode.url != null) {
        final url = barcode.url!;
        if (qrData == null || qrData.isEmpty) {
          qrData = url.url;
        }
      }

      if (qrData != null && qrData.isNotEmpty) {
        setState(() {
          isScanning = false;
        });
        _navigateToResult(qrData, barcode.format);
        break;
      }
    }
  }

  void _navigateToResult(String result,
      [mobile_scanner.BarcodeFormat? format]) async {
    // Debug: Print detected format
    print('Detected format: $format');
    print('Content: $result');

    // Determine barcode type based on format
    String barcodeType = 'QR Code'; // Default

    if (format != null) {
      switch (format) {
        case mobile_scanner.BarcodeFormat.qrCode:
          barcodeType = 'QR Code';
          break;
        case mobile_scanner.BarcodeFormat.code128:
          barcodeType = 'Code 128';
          break;
        case mobile_scanner.BarcodeFormat.code39:
          barcodeType = 'Code 39';
          break;
        case mobile_scanner.BarcodeFormat.code93:
          barcodeType = 'Code 93';
          break;
        case mobile_scanner.BarcodeFormat.ean13:
          barcodeType = 'EAN-13';
          break;
        case mobile_scanner.BarcodeFormat.ean8:
          barcodeType = 'EAN-8';
          break;
        case mobile_scanner.BarcodeFormat.upcA:
          barcodeType = 'UPC-A';
          break;
        case mobile_scanner.BarcodeFormat.upcE:
          barcodeType = 'UPC-E';
          break;
        default:
          // For unknown formats, try to guess based on content
          barcodeType = _guessBarcodeType(result);
          break;
      }
    } else {
      // When format is not available, guess based on content
      barcodeType = _guessBarcodeType(result);
      print('Format not detected, guessed: $barcodeType');
    }

    print('Final barcode type: $barcodeType');

    // Navigate to result page (ScanResultPage will handle saving to history)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultPage(
          type: barcodeType,
          content: result,
          timestamp: DateTime.now(),
        ),
      ),
    );

    // Auto-restart scanning after returning from result page
    setState(() {
      isScanning = true;
    });
  }

  String _guessBarcodeType(String content) {
    // Analyze content to guess barcode type

    // QR Code characteristics
    if (content.contains('http://') ||
        content.contains('https://') ||
        content.contains('mailto:') ||
        content.contains('tel:') ||
        content.contains('geo:') ||
        content.contains('wifi:') ||
        content.contains('BEGIN:VCARD') ||
        content.contains('BEGIN:VCALENDAR') ||
        content.length > 80) {
      return 'QR Code';
    }

    // EAN-13: exactly 13 digits
    if (content.length == 13 && RegExp(r'^\d{13}$').hasMatch(content)) {
      return 'EAN-13';
    }

    // EAN-8: exactly 8 digits
    if (content.length == 8 && RegExp(r'^\d{8}$').hasMatch(content)) {
      return 'EAN-8';
    }

    // UPC-A: 11 digits (without check digit) or 12 digits (with check digit)
    if ((content.length == 11 || content.length == 12) &&
        RegExp(r'^\d+$').hasMatch(content)) {
      return 'UPC-A';
    }

    // UPC-E: 6-7 digits (compact format)
    if ((content.length == 6 || content.length == 7) &&
        RegExp(r'^\d+$').hasMatch(content)) {
      return 'UPC-E';
    }

    // Priority-based detection for linear barcodes

    // Code 128: Most flexible, can encode any ASCII character (0-127)
    // Check for characters that are only supported by Code 128
    bool hasExtendedChars = false;
    for (int i = 0; i < content.length; i++) {
      int charCode = content.codeUnitAt(i);
      // If contains lowercase letters or special characters beyond Code 39/93 set
      if (charCode >= 97 && charCode <= 122) {
        // lowercase a-z
        hasExtendedChars = true;
        break;
      }
      // Other special characters not in Code 39/93
      if (![32, 36, 37, 43, 45, 46, 47]
              .contains(charCode) && // space, $, %, +, -, ., /
          !(charCode >= 48 && charCode <= 57) && // 0-9
          !(charCode >= 65 && charCode <= 90)) {
        // A-Z
        hasExtendedChars = true;
        break;
      }
    }

    if (hasExtendedChars && content.length <= 80) {
      return 'Code 128';
    }

    // Code 93: More compact than Code 39, typically shorter
    // Check for Code 93 characteristics (uppercase alphanumeric + specific symbols)
    if (RegExp(r'^[A-Z0-9\-\.\$\/\+% ]+$').hasMatch(content.toUpperCase()) &&
        content.length >= 1 &&
        content.length <= 30) {
      // Prefer Code 93 for shorter strings with alphanumeric content
      if (content.length <= 20 ||
          (content.contains(RegExp(r'[A-Z]')) &&
              content.contains(RegExp(r'[0-9]')))) {
        return 'Code 93';
      }
    }

    // Code 39: Less dense, typically longer strings
    // Can handle uppercase alphanumeric plus specific symbols
    if (RegExp(r'^[A-Z0-9\-\.\$\/\+% ]+$').hasMatch(content.toUpperCase()) &&
        content.length >= 1 &&
        content.length <= 50) {
      return 'Code 39';
    }

    // Code 128: Final fallback for other content
    if (content.length <= 80 && content.isNotEmpty) {
      return 'Code 128';
    }

    // Default fallback
    return 'Barcode';
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isActive ? color : Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? color : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - _cutOutSize) / 2 + borderOffset,
      rect.top + (height - _cutOutSize) / 2 + borderOffset + cutOutBottomOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    // Background
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              cutOutRect, Radius.circular(borderRadius)))
          ..close(),
      ),
      backgroundPaint,
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      borderPaint,
    );

    final borderPath = Path();

    // Top left
    borderPath.moveTo(
        cutOutRect.left - borderOffset, cutOutRect.top + borderLength);
    borderPath.lineTo(
        cutOutRect.left - borderOffset, cutOutRect.top + borderRadius);
    borderPath.quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.left + borderRadius,
        cutOutRect.top - borderOffset);
    borderPath.lineTo(
        cutOutRect.left + borderLength, cutOutRect.top - borderOffset);

    // Top right
    borderPath.moveTo(
        cutOutRect.right - borderLength, cutOutRect.top - borderOffset);
    borderPath.lineTo(
        cutOutRect.right - borderRadius, cutOutRect.top - borderOffset);
    borderPath.quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.top - borderOffset,
        cutOutRect.right + borderOffset,
        cutOutRect.top + borderRadius);
    borderPath.lineTo(
        cutOutRect.right + borderOffset, cutOutRect.top + borderLength);

    // Bottom right
    borderPath.moveTo(
        cutOutRect.right + borderOffset, cutOutRect.bottom - borderLength);
    borderPath.lineTo(
        cutOutRect.right + borderOffset, cutOutRect.bottom - borderRadius);
    borderPath.quadraticBezierTo(
        cutOutRect.right + borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.right - borderRadius,
        cutOutRect.bottom + borderOffset);
    borderPath.lineTo(
        cutOutRect.right - borderLength, cutOutRect.bottom + borderOffset);

    // Bottom left
    borderPath.moveTo(
        cutOutRect.left + borderLength, cutOutRect.bottom + borderOffset);
    borderPath.lineTo(
        cutOutRect.left + borderRadius, cutOutRect.bottom + borderOffset);
    borderPath.quadraticBezierTo(
        cutOutRect.left - borderOffset,
        cutOutRect.bottom + borderOffset,
        cutOutRect.left - borderOffset,
        cutOutRect.bottom - borderRadius);
    borderPath.lineTo(
        cutOutRect.left - borderOffset, cutOutRect.bottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

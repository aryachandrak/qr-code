import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'native_action_helper.dart';

enum QRCodeType {
  email,
  contact,
  phone,
  url,
  location,
  wifi,
  calendar,
  text,
}

class QRCodeDetector {
  static QRCodeType detectQRType(String data) {
    // Clean the data and convert to lowercase for detection
    final cleanData = data.trim();
    final lowerData = cleanData.toLowerCase();

    // Email detection
    if (lowerData.startsWith('mailto:')) {
      return QRCodeType.email;
    }

    // Contact detection (VCard format)
    if (lowerData.startsWith('begin:vcard')) {
      return QRCodeType.contact;
    }

    // Phone detection
    if (lowerData.startsWith('tel:')) {
      return QRCodeType.phone;
    }

    // URL detection
    if (lowerData.startsWith('http://') || lowerData.startsWith('https://')) {
      return QRCodeType.url;
    }

    // Location detection
    if (lowerData.startsWith('geo:')) {
      return QRCodeType.location;
    }

    // WiFi detection
    if (lowerData.startsWith('wifi:')) {
      return QRCodeType.wifi;
    }

    // Calendar detection
    if (lowerData.startsWith('begin:vcalendar')) {
      return QRCodeType.calendar;
    }

    // Check if it's an email address without mailto: prefix
    if (_isEmailAddress(cleanData)) {
      return QRCodeType.email;
    }

    // Default to text
    return QRCodeType.text;
  }

  static bool _isEmailAddress(String data) {
    // Simple email regex pattern
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(data);
  }

  static Future<void> handleQRAction(BuildContext context, String data) async {
    final type = detectQRType(data);

    switch (type) {
      case QRCodeType.email:
        await _handleEmail(context, data);
        break;
      case QRCodeType.contact:
        await _handleContact(context, data);
        break;
      case QRCodeType.phone:
        await _handlePhone(context, data);
        break;
      case QRCodeType.url:
        await _handleURL(context, data);
        break;
      case QRCodeType.location:
        await _handleLocation(context, data);
        break;
      case QRCodeType.wifi:
        await _handleWifi(context, data);
        break;
      case QRCodeType.calendar:
        await _handleCalendar(context, data);
        break;
      case QRCodeType.text:
        await _handleText(context, data);
        break;
    }
  }

  static Future<void> _handleEmail(BuildContext context, String data) async {
    try {
      String emailUri = data;

      // If it's just an email address without mailto: prefix, add it
      if (!data.toLowerCase().startsWith('mailto:')) {
        emailUri = 'mailto:$data';
      }

      // Parse email data
      final emailData = _parseEmailData(data);

      // Try to launch email app directly
      await _launchEmail(context, emailUri, emailData);
    } catch (e) {
      _showErrorDialog(context, 'Error processing email: $e');
    }
  }

  static Map<String, String> _parseEmailData(String data) {
    final Map<String, String> emailData = {};

    if (data.toLowerCase().startsWith('mailto:')) {
      try {
        final uri = Uri.parse(data);

        // Extract email address
        final email = uri.path;
        if (email.isNotEmpty) {
          emailData['email'] = email;
        }

        // Extract query parameters
        final queryParams = uri.queryParameters;
        if (queryParams.containsKey('subject')) {
          emailData['subject'] = queryParams['subject']!;
        }
        if (queryParams.containsKey('body')) {
          emailData['body'] = queryParams['body']!;
        }
        if (queryParams.containsKey('cc')) {
          emailData['cc'] = queryParams['cc']!;
        }
        if (queryParams.containsKey('bcc')) {
          emailData['bcc'] = queryParams['bcc']!;
        }
      } catch (e) {
        // If parsing fails, treat as simple email
        emailData['email'] = data.substring(7); // Remove 'mailto:'
      }
    } else {
      // Simple email address
      emailData['email'] = data;
    }

    return emailData;
  }

  static Future<void> _handleContact(BuildContext context, String data) async {
    try {
      // Parse VCard data
      final contact = _parseVCard(data);

      // Directly save to contacts
      await _saveContact(context, contact);
    } catch (e) {
      _showErrorDialog(context, 'Error parsing contact: $e');
    }
  }

  static Future<void> _handlePhone(BuildContext context, String data) async {
    try {
      final uri = Uri.parse(data);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorDialog(context, 'Cannot open phone dialer');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error opening phone dialer: $e');
    }
  }

  static Future<void> _handleURL(BuildContext context, String data) async {
    try {
      final uri = Uri.parse(data);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, 'Cannot open URL');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error opening URL: $e');
    }
  }

  static Future<void> _handleLocation(BuildContext context, String data) async {
    try {
      // Parse geo: format (geo:lat,lng)
      final coords = data.substring(4).split(',');
      if (coords.length >= 2) {
        final lat = coords[0];
        final lng = coords[1];

        // Try to open in Google Maps
        final mapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        final uri = Uri.parse(mapsUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showErrorDialog(context, 'Cannot open maps application');
        }
      } else {
        _showErrorDialog(context, 'Invalid location format');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error opening location: $e');
    }
  }

  static Future<void> _handleWifi(BuildContext context, String data) async {
    try {
      final wifiInfo = _parseWifiQR(data);

      // Copy WiFi info to clipboard first for user reference
      await _copyWifiToClipboard(wifiInfo);
      
      // Show brief notification with WiFi info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WiFi Info: ${wifiInfo['ssid'] ?? 'Unknown'}\nPassword copied to clipboard'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.purple,
        ),
      );

      // Directly open WiFi settings
      await _openWifiSettings(context);
    } catch (e) {
      _showErrorDialog(context, 'Error parsing WiFi info: $e');
    }
  }

  static Future<void> _handleCalendar(BuildContext context, String data) async {
    try {
      final eventInfo = _parseCalendarQR(data);

      // Directly save to calendar
      await _saveToCalendar(context, eventInfo);
    } catch (e) {
      _showErrorDialog(context, 'Error parsing calendar event: $e');
    }
  }

  static Future<void> _handleText(BuildContext context, String data) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Text Content'),
          content: SingleChildScrollView(
            child: SelectableText(
              data,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static Map<String, String> _parseVCard(String data) {
    final Map<String, String> contact = {};
    final lines = data.split('\n');

    for (final line in lines) {
      if (line.startsWith('FN:')) {
        contact['name'] = line.substring(3);
      } else if (line.startsWith('ORG:')) {
        contact['organization'] = line.substring(4);
      } else if (line.startsWith('TEL:')) {
        contact['phone'] = line.substring(4);
      } else if (line.startsWith('EMAIL:')) {
        contact['email'] = line.substring(6);
      } else if (line.startsWith('ADR:')) {
        contact['address'] = line.substring(4);
      } else if (line.startsWith('NOTE:')) {
        contact['note'] = line.substring(5);
      }
    }

    return contact;
  }

  static Map<String, String> _parseWifiQR(String data) {
    final Map<String, String> wifi = {};

    // Parse WIFI:T:WPA;S:NetworkName;P:Password;;
    final parts = data.substring(5).split(';'); // Remove 'WIFI:' prefix

    for (final part in parts) {
      if (part.startsWith('T:')) {
        wifi['security'] = part.substring(2);
      } else if (part.startsWith('S:')) {
        wifi['ssid'] = part.substring(2);
      } else if (part.startsWith('P:')) {
        wifi['password'] = part.substring(2);
      }
    }

    return wifi;
  }

  static Map<String, String> _parseCalendarQR(String data) {
    final Map<String, String> event = {};
    final lines = data.split('\n');

    for (final line in lines) {
      if (line.startsWith('SUMMARY:')) {
        event['summary'] = line.substring(8);
      } else if (line.startsWith('DESCRIPTION:')) {
        event['description'] = line.substring(12);
      } else if (line.startsWith('LOCATION:')) {
        event['location'] = line.substring(9);
      } else if (line.startsWith('DTSTART:')) {
        event['startDate'] = _formatDateTime(line.substring(8));
      } else if (line.startsWith('DTEND:')) {
        event['endDate'] = _formatDateTime(line.substring(6));
      }
    }

    return event;
  }

  static String _formatDateTime(String isoString) {
    try {
      // Parse ISO format: 20250715T162000Z
      final year = int.parse(isoString.substring(0, 4));
      final month = int.parse(isoString.substring(4, 6));
      final day = int.parse(isoString.substring(6, 8));
      final hour = int.parse(isoString.substring(9, 11));
      final minute = int.parse(isoString.substring(11, 13));

      final dateTime = DateTime(year, month, day, hour, minute);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _saveContact(
      BuildContext context, Map<String, String> contact) async {
    try {
      await NativeActionHelper.openAddContact(contact);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Contact information processed. Check your contacts app or clipboard.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Fallback - copy to clipboard
      await _copyContactToClipboard(contact);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact information copied to clipboard'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> _copyContactToClipboard(
      Map<String, String> contact) async {
    final StringBuffer buffer = StringBuffer();

    if (contact['name'] != null) {
      buffer.writeln('Name: ${contact['name']}');
    }
    if (contact['organization'] != null) {
      buffer.writeln('Organization: ${contact['organization']}');
    }
    if (contact['phone'] != null) {
      buffer.writeln('Phone: ${contact['phone']}');
    }
    if (contact['email'] != null) {
      buffer.writeln('Email: ${contact['email']}');
    }
    if (contact['address'] != null) {
      buffer.writeln('Address: ${contact['address']}');
    }
    if (contact['note'] != null) {
      buffer.writeln('Note: ${contact['note']}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static Future<void> _copyWifiToClipboard(Map<String, String> wifiInfo) async {
    final StringBuffer buffer = StringBuffer();

    if (wifiInfo['ssid'] != null) {
      buffer.writeln('Network Name: ${wifiInfo['ssid']}');
    }
    if (wifiInfo['security'] != null) {
      buffer.writeln('Security: ${wifiInfo['security']}');
    }
    if (wifiInfo['password'] != null && wifiInfo['password']!.isNotEmpty) {
      buffer.writeln('Password: ${wifiInfo['password']}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static Future<void> _openWifiSettings(BuildContext context) async {
    try {
      await NativeActionHelper.openWifiSettings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please go to WiFi settings manually'),
        ),
      );
    }
  }

  static Future<void> _saveToCalendar(
      BuildContext context, Map<String, String> event) async {
    try {
      await NativeActionHelper.openAddCalendarEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Calendar event processed. Check your calendar app or clipboard.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Fallback - copy to clipboard
      await _copyEventToClipboard(event);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calendar event copied to clipboard'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> _copyEventToClipboard(Map<String, String> event) async {
    final StringBuffer buffer = StringBuffer();

    if (event['summary'] != null) {
      buffer.writeln('Title: ${event['summary']}');
    }
    if (event['description'] != null) {
      buffer.writeln('Description: ${event['description']}');
    }
    if (event['location'] != null) {
      buffer.writeln('Location: ${event['location']}');
    }
    if (event['startDate'] != null) {
      buffer.writeln('Start Date: ${event['startDate']}');
    }
    if (event['endDate'] != null) {
      buffer.writeln('End Date: ${event['endDate']}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  static String getQRTypeName(QRCodeType type) {
    switch (type) {
      case QRCodeType.email:
        return 'Email';
      case QRCodeType.contact:
        return 'Contact';
      case QRCodeType.phone:
        return 'Phone';
      case QRCodeType.url:
        return 'URL';
      case QRCodeType.location:
        return 'Location';
      case QRCodeType.wifi:
        return 'WiFi';
      case QRCodeType.calendar:
        return 'Calendar';
      case QRCodeType.text:
        return 'Text';
    }
  }

  static IconData getQRTypeIcon(QRCodeType type) {
    switch (type) {
      case QRCodeType.email:
        return Icons.email;
      case QRCodeType.contact:
        return Icons.contact_page;
      case QRCodeType.phone:
        return Icons.phone;
      case QRCodeType.url:
        return Icons.link;
      case QRCodeType.location:
        return Icons.location_on;
      case QRCodeType.wifi:
        return Icons.wifi;
      case QRCodeType.calendar:
        return Icons.calendar_today;
      case QRCodeType.text:
        return Icons.text_fields;
    }
  }

  static Future<void> _launchEmail(BuildContext context, String emailUri,
      Map<String, String> emailData) async {
    try {
      // Try multiple approaches to open email

      // Approach 1: Try to launch mailto URL directly
      final uri = Uri.parse(emailUri);
      if (await canLaunchUrl(uri)) {
        try {
          await launchUrl(uri);
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening email app for ${emailData['email'] ?? 'email'}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        } catch (e) {
          // Continue to next approach
        }
      }

      // Approach 2: Try different launch modes
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening email app for ${emailData['email'] ?? 'email'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      } catch (e) {
        // Continue to next approach
      }

      // Approach 3: Try system default
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening email app for ${emailData['email'] ?? 'email'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      } catch (e) {
        // Continue to next approach
      }

      // Approach 4: Try with different URI schemes
      if (emailData['email'] != null) {
        try {
          final simpleUri = Uri.parse('mailto:${emailData['email']}');
          await launchUrl(simpleUri);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening email app for ${emailData['email']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        } catch (e) {
          // Continue to next approach
        }
      }

      // Fallback: Copy to clipboard and show message
      await _copyEmailToClipboard(context, emailData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open email app. Email information copied to clipboard.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      await _copyEmailToClipboard(context, emailData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error opening email app. Information copied to clipboard.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> _copyEmailToClipboard(
      BuildContext context, Map<String, String> emailData) async {
    final StringBuffer buffer = StringBuffer();

    if (emailData['email'] != null) {
      buffer.writeln('Email: ${emailData['email']}');
    }
    if (emailData['subject'] != null) {
      buffer.writeln('Subject: ${emailData['subject']}');
    }
    if (emailData['body'] != null) {
      buffer.writeln('Body: ${emailData['body']}');
    }
    if (emailData['cc'] != null) {
      buffer.writeln('CC: ${emailData['cc']}');
    }
    if (emailData['bcc'] != null) {
      buffer.writeln('BCC: ${emailData['bcc']}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email information copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

}

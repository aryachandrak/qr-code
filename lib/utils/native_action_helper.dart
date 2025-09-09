import 'dart:io';
import 'package:flutter/services.dart';

class NativeActionHelper {
  static const MethodChannel _channel =
      MethodChannel('qris_app/native_actions');

  /// Open native contacts app to add contact
  static Future<void> openAddContact(Map<String, String> contact) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openAddContact', contact);
      } catch (e) {
        // Fallback - copy contact info to clipboard
        await _copyContactToClipboard(contact);
      }
    } else {
      // For iOS or other platforms, copy to clipboard
      await _copyContactToClipboard(contact);
    }
  }

  /// Open native calendar app to add event
  static Future<void> openAddCalendarEvent(Map<String, String> event) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openAddCalendarEvent', event);
      } catch (e) {
        // Fallback - copy event info to clipboard
        await _copyEventToClipboard(event);
      }
    } else {
      // For iOS or other platforms, copy to clipboard
      await _copyEventToClipboard(event);
    }
  }

  /// Open native WiFi settings
  static Future<void> openWifiSettings() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openWifiSettings');
      } catch (e) {
        // Silently handle WiFi settings error
      }
    }
  }

  /// Copy contact information to clipboard
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
}

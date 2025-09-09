package com.example.qris_app

import android.content.Intent
import android.provider.ContactsContract
import android.provider.CalendarContract
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "qris_app/native_actions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openAddContact" -> {
                    val contact = call.arguments as Map<String, String>
                    openAddContact(contact)
                    result.success(null)
                }
                "openAddCalendarEvent" -> {
                    val event = call.arguments as Map<String, String>
                    openAddCalendarEvent(event)
                    result.success(null)
                }
                "openWifiSettings" -> {
                    openWifiSettings()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openAddContact(contact: Map<String, String>) {
        val intent = Intent(ContactsContract.Intents.Insert.ACTION).apply {
            type = ContactsContract.RawContacts.CONTENT_TYPE
            contact["name"]?.let { putExtra(ContactsContract.Intents.Insert.NAME, it) }
            contact["organization"]?.let { putExtra(ContactsContract.Intents.Insert.COMPANY, it) }
            contact["phone"]?.let { putExtra(ContactsContract.Intents.Insert.PHONE, it) }
            contact["email"]?.let { putExtra(ContactsContract.Intents.Insert.EMAIL, it) }
            contact["address"]?.let { putExtra(ContactsContract.Intents.Insert.POSTAL, it) }
            contact["note"]?.let { putExtra(ContactsContract.Intents.Insert.NOTES, it) }
        }
        startActivity(intent)
    }

    private fun openAddCalendarEvent(event: Map<String, String>) {
        val intent = Intent(Intent.ACTION_INSERT).apply {
            data = CalendarContract.Events.CONTENT_URI
            event["summary"]?.let { putExtra(CalendarContract.Events.TITLE, it) }
            event["description"]?.let { putExtra(CalendarContract.Events.DESCRIPTION, it) }
            event["location"]?.let { putExtra(CalendarContract.Events.EVENT_LOCATION, it) }
            // Note: For simplicity, we're not parsing the datetime strings here
            // In a real app, you would parse the datetime and set BEGIN_TIME and END_TIME
        }
        startActivity(intent)
    }

    private fun openWifiSettings() {
        val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
        startActivity(intent)
    }
}

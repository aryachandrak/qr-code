import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/qr_download_util.dart';

class CalendarQRScreen extends StatefulWidget {
  const CalendarQRScreen({super.key});

  @override
  State<CalendarQRScreen> createState() => _CalendarQRScreenState();
}

class _CalendarQRScreenState extends State<CalendarQRScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String qrData = '';
  final GlobalKey qrKey = GlobalKey();

  String _generateVEvent() {
    if (startDate == null || startTime == null) return '';

    DateTime startDateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );

    DateTime endDateTime = endDate != null && endTime != null
        ? DateTime(
            endDate!.year,
            endDate!.month,
            endDate!.day,
            endTime!.hour,
            endTime!.minute,
          )
        : startDateTime.add(const Duration(hours: 1));

    String formatDateTime(DateTime dt) {
      return '${dt
              .toUtc()
              .toIso8601String()
              .replaceAll('-', '')
              .replaceAll(':', '')
              .split('.')[0]}Z';
    }

    return '''BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//QRIS App//Event//EN
BEGIN:VEVENT
DTSTART:${formatDateTime(startDateTime)}
DTEND:${formatDateTime(endDateTime)}
SUMMARY:${_titleController.text}
DESCRIPTION:${_descriptionController.text}
LOCATION:${_locationController.text}
END:VEVENT
END:VCALENDAR''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar QR Code'),
        centerTitle: true,        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter event information:',
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
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Event Title *',
                        prefixIcon: Icon(Icons.event),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  startDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 8),
                                  Text(
                                    startDate != null
                                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                        : 'Start Date *',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  startTime = time;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 8),
                                  Text(
                                    startTime != null
                                        ? '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'
                                        : 'Start Time *',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  endDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 8),
                                  Text(
                                    endDate != null
                                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                        : 'End Date',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  endTime = time;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time),
                                  const SizedBox(width: 8),
                                  Text(
                                    endTime != null
                                        ? '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'
                                        : 'End Time',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.trim().isNotEmpty &&
                            startDate != null &&
                            startTime != null) {
                          setState(() {
                            qrData = _generateVEvent();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Title, start date, and start time are required')),
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
                              'Event Information:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Title: ${_titleController.text}'),
                            if (_descriptionController.text.isNotEmpty)
                              Text(
                                  'Description: ${_descriptionController.text}'),
                            if (_locationController.text.isNotEmpty)
                              Text('Location: ${_locationController.text}'),
                            if (startDate != null && startTime != null)
                              Text(
                                  'Start: ${startDate!.day}/${startDate!.month}/${startDate!.year} ${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'),
                            if (endDate != null && endTime != null)
                              Text(
                                  'End: ${endDate!.day}/${endDate!.month}/${endDate!.year} ${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Scanning this QR code will add event to calendar',
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
                                  _titleController.clear();
                                  _descriptionController.clear();
                                  _locationController.clear();
                                  startDate = null;
                                  endDate = null;
                                  startTime = null;
                                  endTime = null;
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
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/court_booking.dart';
import '../server/database_helper.dart';
import 'home_page.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key});

  static const List<_CourtCardData> _courtCards = [
    _CourtCardData(
      name: 'Court 1',
      type: 'สนามแบดมินตัน',
      status: 'ว่าง',
      imagePath: 'lib/image/1.jpg',
      color: Color(0xFF16A34A),
    ),
    _CourtCardData(
      name: 'Court 2',
      type: 'สนามเทนนิส',
      status: 'ไม่ว่าง',
      imagePath: 'lib/image/2.jpg',
      color: Color(0xFFF59E0B),
    ),
    _CourtCardData(
      name: 'Court 3',
      type: 'สนามแบดมินตัน',
      status: 'ว่าง',
      imagePath: 'lib/image/1.jpg',
      color: Color(0xFF2563EB),
    ),
    _CourtCardData(
      name: 'Court 4',
      type: 'สนามแบดมินตัน',
      status: 'ไม่ว่าง',
      imagePath: 'lib/image/1.jpg',
      color: Color(0xFF7C3AED),
    ),
    _CourtCardData(
      name: 'Court 5',
      type: 'สนามเทนนิส',
      status: 'ว่าง',
      imagePath: 'lib/image/2.jpg',
      color: Color(0xFF0EA5E9),
    ),
    _CourtCardData(
      name: 'Court 6',
      type: 'สนามแบดมินตัน',
      status: 'ไม่ว่าง',
      imagePath: 'lib/image/1.jpg',
      color: Color(0xFFEF4444),
    ),
  ];
//หน้าการจอง
  Future<void> _showBookingDialog(BuildContext context, WidgetRef ref, _CourtCardData court) async {
    final courtController = TextEditingController(text: court.name);
    final timeController = TextEditingController(text: '18:00 - 19:00');
    String fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final dateController = TextEditingController(text: fmtDate(DateTime.now()));
    final bookedByController = TextEditingController();
    final priceController = TextEditingController(text: '100');
    final statusController = TextEditingController(text: 'จอง');
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 18, minute: 0);
    final statusOptions = ['จอง', 'ว่าง'];
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'เพิ่มการจอง',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: courtController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อสนาม',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            selectedTime = pickedTime;
                            final start = pickedTime.format(context);
                            final endHour = (pickedTime.hour + 1) % 24;
                            final endMinute = pickedTime.minute;
                            final end = TimeOfDay(hour: endHour, minute: endMinute).format(context);
                            timeController.text = '$start - $end';
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: timeController,
                            decoration: const InputDecoration(
                              labelText: 'เวลา',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            selectedDate = pickedDate;
                            dateController.text = fmtDate(pickedDate);
                            setState(() {});
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: dateController,
                            decoration: const InputDecoration(
                              labelText: 'วันที่',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: bookedByController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อผู้จอง',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'กรุณากรอกชื่อผู้จอง' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ราคา / ชั่วโมง(100/1ชม.)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: statusController.text,
                        decoration: const InputDecoration(
                          labelText: 'สถานะ',
                          border: OutlineInputBorder(),
                        ),
                        items: statusOptions
                            .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            statusController.text = value;
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!(formKey.currentState?.validate() ?? false)) return;

                                  final newBooking = CourtBooking(
                                    courtName: courtController.text.trim(),
                                    hour: timeController.text.trim(),
                                    date: dateController.text.trim(),
                                    bookedBy: bookedByController.text.trim(),
                                    hourlyRate: double.tryParse(priceController.text.trim()) ?? 250,
                                    status: statusController.text.trim(),
                                  );

                                  setState(() => isSaving = true);
                                  try {
                                    await DatabaseHelper.instance.insertBooking(newBooking);
                                  } catch (e) {
                                    setState(() => isSaving = false);
                                    if (sheetContext.mounted) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
                                      );
                                    }
                                    return;
                                  }

                                  // รีเฟรชข้อมูลหน้า Home
                                  ref.invalidate(bookingListProvider);
                                  ref.invalidate(summaryProvider);

                                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                                  ref.read(selectedTabProvider.notifier).state = 0;
                                },
                          icon: const Icon(Icons.check),
                          label: const Text('บันทึกข้อมูล'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingListProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final bookedCourtNames = bookings
            .where((booking) {
              final normalizedStatus = booking.status.trim();
              return normalizedStatus == 'จอง' ||
                  normalizedStatus == 'Booked' ||
                  normalizedStatus == 'booked' ||
                  normalizedStatus == 'ไม่ว่าง' ||
                  normalizedStatus == 'Unavailable';
            })
            .map((booking) => booking.courtName.trim())
            .toSet();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text('Book a court'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF7E8),
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'สนาม',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Comic Sans MS',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    itemCount: _courtCards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final court = _courtCards[index];
                      final isAvailable = !bookedCourtNames.contains(court.name);

                      return GestureDetector(
                        onTap: isAvailable ? () => _showBookingDialog(context, ref, court) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black54, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Image.asset(
                                  court.imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.sports_tennis,
                                      size: 54,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                court.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                court.type,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isAvailable ? Colors.blue : Colors.red,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAvailable ? 'ว่าง' : 'ไม่ว่าง',
                                  style: TextStyle(
                                    color: isAvailable ? Colors.blue : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Unable to load court status')),
      ),
    );
  }
}

class _CourtCardData {
  final String name;
  final String type;
  final String status;
  final String imagePath;
  final Color color;

  const _CourtCardData({
    required this.name,
    required this.type,
    required this.status,
    required this.imagePath,
    required this.color,
  });
}
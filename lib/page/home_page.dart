import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/court_booking.dart';
import '../server/weather_service.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

//  สถานที่สำหรับดูสภาพอากาศ
class WeatherLocation {
  final String name;
  final double lat;
  final double lon;
  const WeatherLocation(this.name, this.lat, this.lon);
}

const weatherLocations = [
  WeatherLocation('Bangkok', 13.7563, 100.5018),
  WeatherLocation('Nakhon Pathom', 13.8199, 100.0621),
  WeatherLocation('Chiang Mai', 18.7883, 98.9853),
  WeatherLocation('Phuket', 7.8804, 98.3923),
  WeatherLocation('Khon Kaen', 16.4419, 102.8360),
];

final selectedLocationProvider =
    StateProvider<WeatherLocation>((ref) => weatherLocations.first);

final weatherProvider = FutureProvider<WeatherReport>((ref) async {
  final loc = ref.watch(selectedLocationProvider);
  final service = WeatherService(
    city: loc.name,
    latitude: loc.lat,
    longitude: loc.lon,
  );
  return service.fetchWeather();
});

// ดึงข้อมูลการจองแบบ court_bookings
final bookingListProvider = StreamProvider<List<CourtBooking>>((ref) {
  return FirebaseFirestore.instance
      .collection('court_bookings')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return CourtBooking(
            id: doc.id,
            courtName: data['courtName'] ?? '',
            hour: data['hour'] ?? '',
            date: data['date'] ?? '',
            bookedBy: data['bookedBy'] ?? '',
            hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0,
            status: data['status'] ?? '',
          );
        }).toList();
      });
});


class SummaryData {
  final int bookings;
  final double income;
  const SummaryData({required this.bookings, required this.income});
}

final summaryProvider = Provider<AsyncValue<SummaryData>>((ref) {
  final bookingsAsync = ref.watch(bookingListProvider);

  if (bookingsAsync.hasError) {
    return AsyncValue.error(bookingsAsync.error!, bookingsAsync.stackTrace!);
  }
  if (!bookingsAsync.hasValue) return const AsyncValue.loading();

  final bookings = bookingsAsync.value!;
  final totalIncome = bookings.fold<double>(
    0,
    (sum, booking) => sum + booking.hourlyRate,
  );

  return AsyncValue.data(
    SummaryData(bookings: bookings.length, income: totalIncome),
  );
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final summaryAsync = ref.watch(summaryProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking record'),
        backgroundColor: const Color.fromARGB(255, 155, 180, 239),
        foregroundColor: const Color.fromARGB(255, 45, 25, 172),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // เลือกสถานที่ 
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      DropdownButton<WeatherLocation>(
                        value: selectedLocation,
                        underline: const SizedBox.shrink(),
                        items: weatherLocations
                            .map(
                              (loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc.name),
                              ),
                            )
                            .toList(),
                        onChanged: (loc) {
                          if (loc != null) {
                            ref.read(selectedLocationProvider.notifier).state =
                                loc;
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ▲ จบตัวเลือกสถานที่ ▲

                  weatherAsync.when(
                    data: (weather) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Court Sharing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${weather.temperature.toStringAsFixed(0)}°C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${weather.city} • ${weather.statusText}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            weather.precipitation > 0
                                ? Icons.grain
                                : Icons.wb_sunny_rounded,
                            color: weather.precipitation > 0
                                ? Colors.white
                                : Colors.amber,
                            size: 80,
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 130,
                      child: Center(child: LinearProgressIndicator()),
                    ),
                    error: (_, __) => const Text('Weather service unavailable'),
                  ),
                  const SizedBox(height: 24),

                  summaryAsync.when(
                    data: (summary) {
                      final cards = [
                        _SummaryCard(
                          label: 'Active bookings',
                          value: '${summary.bookings}',
                          icon: Icons.calendar_month,
                          color: Colors.teal,
                        ),
                        _SummaryCard(
                          label: 'Income',
                          value: '฿${summary.income.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.amber,
                        ),
                      ];

                      return GridView.count(
                        crossAxisCount: isWide ? 2 : 1,
                        shrinkWrap: true,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isWide ? 2.2 : 2.5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: cards,
                      );
                    },
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Today\'s schedule',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const _ScheduleList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleList extends ConsumerWidget {
  const _ScheduleList();

  // ลบข้อมูล
  Future<bool> _deleteBooking(
    BuildContext context,
    CourtBooking booking,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: Text(
            'คุณต้องการลบรายการ\n'
            '${booking.courtName} • ${booking.hour}\n'
            'ของ ${booking.bookedBy} ใช่หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return false;
    }

    try {
      await FirebaseFirestore.instance
          .collection('court_bookings')
          .doc(booking.id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบข้อมูลเรียบร้อยแล้ว')),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ลบข้อมูลไม่สำเร็จ: $e')),
        );
      }

      return false;
    }
  }

  // แก้ไข
  Future<void> _editBooking(
    BuildContext context,
    CourtBooking booking,
  ) async {
    final courtNameController = TextEditingController(text: booking.courtName);
    final hourController = TextEditingController(text: booking.hour);
    final dateController = TextEditingController(text: booking.date);
    final bookedByController = TextEditingController(text: booking.bookedBy);
    final hourlyRateController = TextEditingController(
      text: booking.hourlyRate.toStringAsFixed(0),
    );

    String selectedStatus = booking.status.trim();
    if (selectedStatus == 'ว่าง' ||
        selectedStatus == 'available' ||
        selectedStatus == 'Available') {
      selectedStatus = 'ว่าง';
    } else {
      selectedStatus = 'จอง';
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('แก้ไขข้อมูลการจอง'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: courtNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสนาม',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hourController,
                      decoration: const InputDecoration(
                        labelText: 'เวลา',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'วันที่',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bookedByController,
                      decoration: const InputDecoration(
                        labelText: 'ผู้จอง',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'ราคา/ชั่วโมง',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'สถานะ',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'จอง', child: Text('จองแล้ว')),
                        DropdownMenuItem(value: 'ว่าง', child: Text('ว่าง')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final rate = double.tryParse(hourlyRateController.text);

                    if (courtNameController.text.trim().isEmpty ||
                        hourController.text.trim().isEmpty ||
                        dateController.text.trim().isEmpty ||
                        bookedByController.text.trim().isEmpty ||
                        rate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('court_bookings')
                          .doc(booking.id)
                          .update({
                        'courtName': courtNameController.text.trim(),
                        'hour': hourController.text.trim(),
                        'date': dateController.text.trim(),
                        'bookedBy': bookedByController.text.trim(),
                        'hourlyRate': rate,
                        'status': selectedStatus,
                      });

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('แก้ไขข้อมูลเรียบร้อยแล้ว'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('แก้ไขข้อมูลไม่สำเร็จ: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    // ป้องกัน memory leak
    courtNameController.dispose();
    hourController.dispose();
    dateController.dispose();
    bookedByController.dispose();
    hourlyRateController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingListProvider);

    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('ไม่มีรายการจองสำหรับวันนี้')),
            ),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final booking = bookings[index];

            return Dismissible(
              key: ValueKey(booking.id),
              direction: DismissDirection.horizontal,

              // Swipe ซ้าย -> ขวา = แก้ไข
              background: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'แก้ไข',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ขวา -> ซ้าย = ลบ
              secondaryBackground: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ลบ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete, color: Colors.white),
                  ],
                ),
              ),

              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _deleteBooking(context, booking);
                }

                if (direction == DismissDirection.startToEnd) {
                  await _editBooking(context, booking);
                  return false;
                }

                return false;
              },

              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.sports_tennis),
                  ),
                  title: Text('${booking.courtName} • ${booking.hour}'),
                  subtitle: Text('${booking.bookedBy} • ${booking.status}'),
                  trailing: Text('฿${booking.hourlyRate.toStringAsFixed(0)}'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Could not load schedule'),
    );
  }
}
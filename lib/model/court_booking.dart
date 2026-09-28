class CourtBooking {
  final String? id; // เปลี่ยนจาก int? เป็น String?
  final String courtName;
  final String hour;
  final String date;
  final String bookedBy;
  final double hourlyRate;
  final String status;

  const CourtBooking({
    this.id,
    required this.courtName,
    required this.hour,
    required this.date,
    required this.bookedBy,
    required this.hourlyRate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courtName': courtName,
      'hour': hour,
      'date': date,
      'bookedBy': bookedBy,
      'hourlyRate': hourlyRate,
      'status': status,
    };
  }

  factory CourtBooking.fromMap(Map<String, dynamic> map) {
    return CourtBooking(
      id: map['id'] as String?, // เปลี่ยนเป็น String?
      courtName: map['courtName'] as String,
      hour: map['hour'] as String,
      date: map['date'] as String,
      bookedBy: map['bookedBy'] as String,
      hourlyRate: (map['hourlyRate'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}

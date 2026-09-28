import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/court_booking.dart';
import '../model/member.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertMember(Member member) async {
    await _firestore.collection('members').add(member.toMap());
  }

  Future<List<Member>> getMembers() async {
    final snapshot = await _firestore.collection('members').get();
    return snapshot.docs.map((doc) {
      final map = doc.data();
      map['id'] = int.tryParse(doc.id) ?? doc.id.hashCode;
      return Member.fromMap(map);
    }).toList();
  }

  Future<void> updateMember(Member member) async {
    if (member.id == null) return;
    await _firestore.collection('members').doc(member.id.toString()).update(member.toMap());
  }

  Future<void> deleteMember(int id) async {
    await _firestore.collection('members').doc(id.toString()).delete();
  }

  Future<void> insertBooking(CourtBooking booking) async {
    final data = booking.toMap();
    data.remove('id');
    await _firestore.collection('court_bookings').add(data);
  }

  Future<List<CourtBooking>> getBookings() async {
    final snapshot = await _firestore.collection('court_bookings').get();
    return snapshot.docs.map((doc) {
      final map = doc.data();
      map['id'] = int.tryParse(doc.id) ?? doc.id.hashCode;
      return CourtBooking.fromMap(map);
    }).toList();
  }

  Future<void> updateBooking(CourtBooking booking) async {
    if (booking.id == null) return;
    final data = booking.toMap();
    data.remove('id');
    await _firestore.collection('court_bookings').doc(booking.id.toString()).update(data);
  }

  Future<void> deleteBooking(int id) async {
    await _firestore.collection('court_bookings').doc(id.toString()).delete();
  }
}

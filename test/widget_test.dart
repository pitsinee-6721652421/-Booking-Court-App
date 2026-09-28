

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookingcourtapp/main.dart';
import 'package:bookingcourtapp/page/booking_page.dart';

void main() {
  testWidgets('App shows dashboard and member management', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SportBuddyApp()));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Member Group'), findsOneWidget);
    expect(find.text('Book a court'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('Booking page shows six tennis courts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: BookingPage())));
    await tester.pumpAndSettle();

    final courtNames = ['Court 1', 'Court 2', 'Court 3', 'Court 4', 'Court 5', 'Court 6'];

    for (final courtName in courtNames) {
      expect(find.text(courtName), findsAtLeastNWidgets(1));
    }
  });
}

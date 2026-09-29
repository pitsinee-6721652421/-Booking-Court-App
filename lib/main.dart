import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'page/booking_page.dart';
import 'page/home_page.dart';
import 'page/login_page.dart';
import 'page/member_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: SportBuddyApp()));
}

class SportBuddyApp extends StatelessWidget {
  const SportBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Court App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),

      home: const LoginPage(),
    );
  }
}

//หน้าแอป logo

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // แสดง Splash Screen 2 วินาที
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SportBuddyHome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้แอป
            Image.asset(
              'lib/image/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // ชื่อแอป
            const Text(
              'Booking Court App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 3, 164, 95),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'ระบบจองสนามกีฬา',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Loading
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// หน้าหลักของแอป
// =====================================================

class SportBuddyHome extends ConsumerStatefulWidget {
  const SportBuddyHome({super.key});

  @override
  ConsumerState<SportBuddyHome> createState() => _SportBuddyHomeState();
}

class _SportBuddyHomeState extends ConsumerState<SportBuddyHome> {
  static const List<Widget> _pages = [HomePage(), MemberPage(), BookingPage()];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        onTap: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Member Group',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis_outlined),
            label: 'Book a court',
          ),
        ],
      ),
    );
  }
}

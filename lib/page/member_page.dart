import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/member.dart';

final memberListProvider = Provider<List<Member>>((ref) {
  return const [
    Member(
      id: 1,
      name: 'พิชญ์สินี แก้วจันทร์แดง',
      id1: '6721652421',
      image: 'lib/image/member1.jpg',
    ),
    Member(
      id: 2,
      name: 'อนันต์ วารีรัตน์',
      id1: '6721652781',
      image: 'lib/image/member2.jpg',
    ),
  ];
});

class MemberPage extends ConsumerWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(memberListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        title: const Text('Member Group'),
        backgroundColor: const Color.fromARGB(255, 242, 87, 165),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: GridView.builder(
          itemCount: members.length,

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),

          itemBuilder: (context, index) {
            final member = members[index];

            return Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // รูปสมาชิก
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      member.image,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFDEE6FF),
                           
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF2D4BA0),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ชื่อ
                  Text(
                    member.name,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // รหัสนักศึกษา
                  Text(
                    member.id1,

                    style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 55, 53, 53)),
                  ),

                  const SizedBox(height: 6),

                  // Level
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

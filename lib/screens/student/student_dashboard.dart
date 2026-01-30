import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الطالب"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 100, color: Colors.amber),
            const SizedBox(height: 16),
            const Text("مرحباً بك!", style: TextStyle(fontSize: 24)),
            const Text("لديك 15 نجمة هذا الأسبوع"),
          ],
        ),
      ),
    );
  }
}

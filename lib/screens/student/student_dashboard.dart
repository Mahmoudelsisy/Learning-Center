import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/auth_provider.dart';
import '../shared/homework_list_screen.dart';
import '../shared/evaluation_list_screen.dart';
import '../shared/material_list_screen.dart';
import '../shared/notification_list_screen.dart';
import '../shared/attendance_history_screen.dart';
import '../../utils/app_colors.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel!;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStarSection(context, user.uid).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(context, "الواجبات", Icons.assignment, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkListScreen()));
                }),
                _buildCard(context, "التقييمات", Icons.bar_chart, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EvaluationListScreen(studentId: user.uid)));
                }),
                _buildCard(context, "المواد العلمية", Icons.menu_book, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialListScreen()));
                }),
                _buildCard(context, "سجل الحضور", Icons.calendar_month, Colors.teal, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen(studentId: user.uid)));
                }),
                _buildCard(context, "التنبيهات", Icons.notifications, Colors.redAccent, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListScreen(uid: user.uid)));
                }),
                _buildCard(context, "الملف الشخصي", Icons.person, Colors.purple, () {
                  // Link to profile
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarSection(BuildContext context, String uid) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().child('students_profiles').child(uid).child('total_stars').onValue,
      builder: (context, snapshot) {
        int stars = 0;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          stars = snapshot.data!.snapshot.value as int;
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              const Icon(Icons.stars, size: 80, color: Colors.amberAccent),
              const SizedBox(height: 12),
              const Text("رصيدك من النجوم", style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("$stars", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder<DataSnapshot>(
                stream: FirebaseDatabase.instance.ref().child('students_profiles').child(uid).child('badges').onValue.map((e) => e.snapshot),
                builder: (context, badgeSnap) {
                  if (!badgeSnap.hasData || badgeSnap.data!.value == null) return const SizedBox();
                  final badges = List<String>.from(badgeSnap.data!.value as List);
                  return Wrap(
                    spacing: 4,
                    children: badges.map((b) => const Icon(Icons.workspace_premium, color: Colors.amberAccent, size: 28)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }
}

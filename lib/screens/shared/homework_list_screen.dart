import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/homework_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../admin/homework_submissions_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeworkListScreen extends StatelessWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkRef = FirebaseDatabase.instance.ref().child('homeworks');
    final user = Provider.of<AuthProvider>(context).userModel!;

    return Scaffold(
      appBar: AppBar(title: const Text("الواجبات المنزلية")),
      body: StreamBuilder(
        stream: homeworkRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<HomeworkModel> homeworks = data.entries
                .map((e) => HomeworkModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: homeworks.length,
              itemBuilder: (context, index) {
                final hw = homeworks[index];
                return _buildHomeworkCard(context, hw, user);
              },
            );
          }
          return const Center(child: Text("لا توجد واجبات حالية"));
        },
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkModel hw, UserModel user) {
    final submissionRef = FirebaseDatabase.instance.ref().child('submissions').child(hw.id).child(user.uid);

    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref().child('sessions').child(hw.sessionId).get(),
      builder: (context, sessionSnap) {
        String sessionTitle = "جلسة...";
        if (sessionSnap.hasData && sessionSnap.data!.value != null) {
          sessionTitle = (sessionSnap.data!.value as Map)['title'] ?? "جلسة غير معروفة";
        }

        return StreamBuilder<DataSnapshot>(
          stream: submissionRef.onValue.map((event) => event.snapshot),
          builder: (context, subSnap) {
            final isSubmitted = subSnap.hasData && subSnap.data!.value != null;
            final status = isSubmitted ? (subSnap.data!.value as Map)['status'] : 'pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(hw.description, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("الموضوع: $sessionTitle", textAlign: TextAlign.right),
                          Text("موعد التسليم: ${hw.deadline.toLocal()}".split(' ')[0], textAlign: TextAlign.right),
                        ],
                      ),
                      leading: Icon(
                        status == 'completed' ? Icons.check_circle : Icons.assignment_turned_in,
                        color: status == 'completed' ? Colors.green : Colors.blue,
                        size: 32,
                      ),
                    ),
                    if (user.role == UserRole.student)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isSubmitted)
                              Text(status == 'completed' ? "تم التسليم ✅" : "قيد المراجعة", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            else
                              ElevatedButton(
                                onPressed: () => _submitHomework(hw.id, user.uid),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: const Text("تسليم الواجب"),
                              ),
                          ],
                        ),
                      ),
                    if (user.role == UserRole.admin)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeworkSubmissionsScreen(homeworkId: hw.id, description: hw.description))),
                          icon: const Icon(Icons.people_outline),
                          label: const Text("عرض التسليمات"),
                        ),
                      )
                  ],
                ),
              ),
            ).animate().fadeIn().slideX();
          },
        );
      },
    );
  }

  void _submitHomework(String hwId, String studentId) async {
    await FirebaseDatabase.instance.ref().child('submissions').child(hwId).child(studentId).set({
      'status': 'completed',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'grade': 0,
      'feedback': '',
    });
  }
}

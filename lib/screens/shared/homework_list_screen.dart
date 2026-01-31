import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/homework_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeworkListScreen extends StatelessWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkRef = FirebaseDatabase.instance.ref().child('homeworks');

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
                return _buildHomeworkCard(context, hw);
              },
            );
          }
          return const Center(child: Text("لا توجد واجبات حالية"));
        },
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkModel hw) {
    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref().child('sessions').child(hw.sessionId).get(),
      builder: (context, sessionSnap) {
        String sessionTitle = "جلسة...";
        if (sessionSnap.hasData && sessionSnap.data!.value != null) {
          sessionTitle = (sessionSnap.data!.value as Map)['title'] ?? "جلسة غير معروفة";
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(hw.description, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("الموضوع: $sessionTitle", textAlign: TextAlign.right),
                Text("موعد التسليم: ${hw.deadline.toLocal()}".split(' ')[0], textAlign: TextAlign.right),
              ],
            ),
            leading: const Icon(Icons.assignment_turned_in, color: Colors.blue),
          ),
        ).animate().fadeIn().slideX();
      },
    );
  }
}

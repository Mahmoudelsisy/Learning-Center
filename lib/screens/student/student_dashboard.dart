import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/auth_provider.dart';
import '../shared/homework_list_screen.dart';
import '../shared/evaluation_list_screen.dart';

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref()
                .child('students_profiles')
                .child(Provider.of<AuthProvider>(context, listen: false).userModel!.uid)
                .child('total_stars')
                .onValue,
            builder: (context, snapshot) {
              int stars = 0;
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                stars = snapshot.data!.snapshot.value as int;
              }
              return Card(
                color: Colors.amberAccent,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.stars, size: 64, color: Colors.orange),
                      const SizedBox(height: 8),
                      Text("رصيد النجوم: $stars",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.assignment, color: Colors.blue),
            title: const Text("الواجبات المنزلية"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkListScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.green),
            title: const Text("تقييم الأداء"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              final uid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
              Navigator.push(context, MaterialPageRoute(builder: (_) => EvaluationListScreen(studentId: uid)));
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
          const Card(
            color: Colors.amberAccent,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.stars, size: 64, color: Colors.orange),
                  SizedBox(height: 8),
                  Text("رصيد النجوم: 15", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
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

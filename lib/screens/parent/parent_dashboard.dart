import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/payment_history_screen.dart';
import '../shared/evaluation_list_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم ولي الأمر"),
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
          ListTile(
            leading: const Icon(Icons.child_care, color: Colors.blue),
            title: const Text("متابعة الأبناء"),
            subtitle: const Text("متابعة الحضور والأداء"),
            onTap: () {
              // Assuming one child for simplicity in this version
              final uid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
              Navigator.push(context, MaterialPageRoute(builder: (_) => EvaluationListScreen(studentId: uid)));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.green),
            title: const Text("الحالة المالية"),
            subtitle: const Text("المبالغ المدفوعة والمتبقية"),
            onTap: () {
              final uid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
              Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen(studentId: uid)));
            },
          ),
        ],
      ),
    );
  }
}

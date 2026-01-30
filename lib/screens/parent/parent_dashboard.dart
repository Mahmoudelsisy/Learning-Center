import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
          const ListTile(
            leading: Icon(Icons.child_care, color: Colors.blue),
            title: Text("أبنائي"),
            subtitle: Text("متابعة الحضور والأداء"),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.payment, color: Colors.green),
            title: Text("الحالة المالية"),
            subtitle: Text("المبالغ المدفوعة والمتبقية"),
          ),
        ],
      ),
    );
  }
}

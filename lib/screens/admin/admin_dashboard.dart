import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم المدير"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          )
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        children: [
          _buildCard(context, "الطلاب", Icons.people, Colors.blue),
          _buildCard(context, "الحضور", Icons.calendar_today, Colors.green),
          _buildCard(context, "المالية", Icons.attach_money, Colors.orange),
          _buildCard(context, "الحصص", Icons.book, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Navigate to specific screen
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

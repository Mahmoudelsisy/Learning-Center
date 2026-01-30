import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'student_management.dart';
import 'session_list_screen.dart';
import 'payment_management_screen.dart';

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
          _buildCard(context, "الطلاب", Icons.people, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagement()));
          }),
          _buildCard(context, "الحضور", Icons.calendar_today, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionListScreen()));
          }),
          _buildCard(context, "المالية", Icons.attach_money, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentManagementScreen()));
          }),
          _buildCard(context, "الحصص", Icons.book, Colors.purple, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionListScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
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

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/payment_history_screen.dart';
import '../shared/evaluation_list_screen.dart';
import '../../utils/app_colors.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel!;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWelcomeHeader(user.name).animate().fadeIn().slideX(),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(context, "متابعة الأبناء", Icons.child_care, Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EvaluationListScreen(studentId: user.uid)));
                }),
                _buildCard(context, "المدفوعات", Icons.payment, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen(studentId: user.uid)));
                }),
                _buildCard(context, "الرسائل", Icons.message, Colors.orange, () {
                  // Link to messages
                }),
                _buildCard(context, "الإعدادات", Icons.settings, Colors.grey, () {
                  // Link to settings
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("مرحباً بك", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          Text(name, style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("تابع أداء أبنائك والمدفوعات بكل سهولة", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/auth_provider.dart';
import '../shared/payment_history_screen.dart';
import '../shared/evaluation_list_screen.dart';
import '../../utils/app_colors.dart';
import '../../services/database_service.dart';
import '../../models/student_profile.dart';
import '../../models/user_model.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel!;
    final dbService = DatabaseService();

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
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("أبنائي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<StudentProfile>>(
              stream: dbService.getChildren(user.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final children = snapshot.data!;

                if (children.isEmpty) {
                  return const Center(child: Text("لم يتم ربط أي أبناء بهذا الحساب بعد."));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final profile = children[index];
                    return FutureBuilder<DataSnapshot>(
                      future: FirebaseDatabase.instance.ref().child('users').child(profile.uid).get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData || userSnap.data!.value == null) return const SizedBox();
                        final studentUser = UserModel.fromMap(userSnap.data!.value as Map, profile.uid);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ExpansionTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(studentUser.name, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              ListTile(
                                leading: const Icon(Icons.bar_chart, color: Colors.green),
                                title: const Text("تقييم الأداء", textAlign: TextAlign.right),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EvaluationListScreen(studentId: profile.uid))),
                              ),
                              ListTile(
                                leading: const Icon(Icons.payment, color: Colors.blue),
                                title: const Text("السجل المالي", textAlign: TextAlign.right),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen(studentId: profile.uid))),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY();
                      },
                    );
                  },
                );
              },
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
}

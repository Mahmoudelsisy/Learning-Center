import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'admin/admin_dashboard.dart';
import 'student/student_dashboard.dart';
import 'parent/parent_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<AuthProvider>(context).userModel;

    if (userModel == null) return const Center(child: Text("Error"));

    switch (userModel.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.student:
        return const StudentDashboard();
      case UserRole.parent:
        return const ParentDashboard();
    }
  }
}

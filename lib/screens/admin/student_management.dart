import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';
import 'student_detail_screen.dart';

import '../../models/student_profile.dart';
import '../../services/database_service.dart';

class StudentManagement extends StatelessWidget {
  const StudentManagement({super.key});

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة طالب جديد", textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "الاسم")),
            TextField(controller: emailController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "البريد الإلكتروني")),
            TextField(controller: phoneController, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: "رقم الهاتف")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال اسم الطالب")));
                return;
              }
              if (phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال رقم الهاتف")));
                return;
              }

              if (nameController.text.isNotEmpty) {
                final userRef = FirebaseDatabase.instance.ref().child('users').push();
                final uid = userRef.key!;

                await userRef.set({
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'role': 'student',
                  'created_at': DateTime.now().millisecondsSinceEpoch,
                });

                final profile = StudentProfile(
                  uid: uid,
                  parentId: "",
                  groupIds: [],
                  paymentType: "monthly",
                  basePrice: 0,
                );
                await DatabaseService().updateStudentProfile(profile);

                Navigator.pop(context);
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref().child('users');

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الطلاب")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        child: const Icon(Icons.person_add),
      ),
      body: StreamBuilder(
        stream: dbRef.orderByChild('role').equalTo('student').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> studentsMap = snapshot.data!.snapshot.value as Map;
            List<UserModel> students = studentsMap.entries
                .map((e) => UserModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(student.phone),
                    trailing: const Icon(Icons.chevron_right, color: Colors.indigo),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailScreen(student: student),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

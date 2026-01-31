import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';
import 'student_detail_screen.dart';

class StudentManagement extends StatelessWidget {
  const StudentManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref().child('users');

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة الطلاب")),
      body: StreamBuilder(
        stream: dbRef.orderByChild('role').equalTo('student').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> studentsMap = snapshot.data!.snapshot.value as Map;
            List<UserModel> students = studentsMap.entries
                .map((e) => UserModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text(student.phone),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailScreen(student: student),
                      ),
                    );
                  },
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

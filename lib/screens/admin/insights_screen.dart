import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';
import '../../utils/analytics_engine.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseDatabase.instance.ref().child('users');
    final attendanceRef = FirebaseDatabase.instance.ref().child('attendance');

    return Scaffold(
      appBar: AppBar(title: const Text("التحليلات والذكاء")),
      body: StreamBuilder(
        stream: studentsRef.orderByChild('role').equalTo('student').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> studentsMap = snapshot.data!.snapshot.value as Map;
            List<UserModel> students = studentsMap.entries
                .map((e) => UserModel.fromMap(e.value, e.key))
                .toList();

            return FutureBuilder<Map<String, List<AttendanceModel>>>(
              future: _fetchAllAttendance(attendanceRef, students),
              builder: (context, attendanceSnapshot) {
                if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final attendanceMap = attendanceSnapshot.data ?? {};

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final history = attendanceMap[student.uid] ?? [];
                    final insight = AnalyticsEngine.analyzeAttendance(history);
                    final isWarning = insight.contains("تنبيه");

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isWarning ? Colors.red.shade50 : null,
                      child: ListTile(
                        title: Text(student.name),
                        subtitle: Text(insight),
                        trailing: Icon(
                          isWarning ? Icons.warning : Icons.info_outline,
                          color: isWarning ? Colors.red : Colors.blue,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text("لا توجد بيانات طلاب حالياً"));
        },
      ),
    );
  }

  Future<Map<String, List<AttendanceModel>>> _fetchAllAttendance(
      DatabaseReference ref, List<UserModel> students) async {
    final Map<String, List<AttendanceModel>> result = {};

    // In a real app, we might want a different structure or query
    // But for MVP, we'll iterate through sessions or students
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> sessions = snapshot.value as Map;
      for (var sessionEntry in sessions.entries) {
        Map<dynamic, dynamic> attendances = sessionEntry.value as Map;
        for (var attEntry in attendances.entries) {
          final studentId = attEntry.key;
          final model = AttendanceModel.fromMap(attEntry.value, studentId);
          result.putIfAbsent(studentId, () => []).add(model);
        }
      }
    }
    return result;
  }
}

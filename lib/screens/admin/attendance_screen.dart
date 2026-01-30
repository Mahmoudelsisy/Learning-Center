import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';

class AttendanceScreen extends StatefulWidget {
  final SessionModel session;
  const AttendanceScreen({super.key, required this.session});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Map<String, AttendanceStatus> attendanceData = {};

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseDatabase.instance.ref().child('users');
    final attendanceRef = FirebaseDatabase.instance.ref().child('attendance').child(widget.session.id);

    return Scaffold(
      appBar: AppBar(title: Text("تحضير: ${widget.session.title}")),
      body: StreamBuilder(
        stream: studentsRef.orderByChild('role').equalTo('student').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> studentsMap = snapshot.data!.snapshot.value as Map;
            List<UserModel> students = studentsMap.entries
                .map((e) => UserModel.fromMap(e.value, e.key))
                .toList();

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        title: Text(student.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusButton(student.uid, AttendanceStatus.present, Colors.green),
                            _buildStatusButton(student.uid, AttendanceStatus.late, Colors.orange),
                            _buildStatusButton(student.uid, AttendanceStatus.absent, Colors.red),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: () => _saveAttendance(attendanceRef),
                    child: const Text("حفظ الكشف"),
                  ),
                )
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusButton(String studentId, AttendanceStatus status, Color color) {
    bool isSelected = attendanceData[studentId] == status;
    return IconButton(
      icon: Icon(
        status == AttendanceStatus.present
            ? Icons.check_circle
            : (status == AttendanceStatus.late ? Icons.access_time_filled : Icons.cancel),
        color: isSelected ? color : Colors.grey,
      ),
      onPressed: () => setState(() => attendanceData[studentId] = status),
    );
  }

  void _saveAttendance(DatabaseReference ref) async {
    final dbService = DatabaseService();
    final adminUid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;

    for (var entry in attendanceData.entries) {
      final attendance = AttendanceModel(
        studentId: entry.key,
        status: entry.value,
        timestamp: DateTime.now(),
      );
      await ref.child(entry.key).set(attendance.toMap());
    }

    await dbService.logAction(
      uid: adminUid,
      action: "RECORD_ATTENDANCE",
      details: "Recorded attendance for session ${widget.session.title}",
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ الحضور بنجاح")));
    Navigator.pop(context);
  }
}

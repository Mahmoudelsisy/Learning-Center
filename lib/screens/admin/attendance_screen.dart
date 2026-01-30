import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../models/attendance_model.dart';
import '../../models/student_profile.dart';
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
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تحضير: ${widget.session.title}")),
      body: StreamBuilder<List<StudentProfile>>(
        stream: _dbService.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final allStudents = snapshot.data!;
            // Filter students who belong to this session's group
            final groupStudents = allStudents.where((s) => s.groupIds.contains(widget.session.groupId)).toList();

            if (groupStudents.isEmpty) {
              return const Center(child: Text("لا يوجد طلاب في هذه المجموعة"));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: groupStudents.length,
                    itemBuilder: (context, index) {
                      final studentProfile = groupStudents[index];
                      return FutureBuilder<DataSnapshot>(
                        future: FirebaseDatabase.instance.ref().child('users').child(studentProfile.uid).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData || userSnapshot.data!.value == null) return const SizedBox();
                          final user = UserModel.fromMap(userSnapshot.data!.value as Map, studentProfile.uid);

                          return ListTile(
                            title: Text(user.name, textAlign: TextAlign.right),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStatusButton(user.uid, AttendanceStatus.present, Colors.green),
                                _buildStatusButton(user.uid, AttendanceStatus.late, Colors.orange),
                                _buildStatusButton(user.uid, AttendanceStatus.absent, Colors.red),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50)
                    ),
                    onPressed: () => _saveAttendance(),
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

  void _saveAttendance() async {
    final adminUid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
    final attendanceRef = FirebaseDatabase.instance.ref().child('attendance').child(widget.session.id);

    for (var entry in attendanceData.entries) {
      final attendance = AttendanceModel(
        studentId: entry.key,
        status: entry.value,
        timestamp: DateTime.now(),
      );
      await attendanceRef.child(entry.key).set(attendance.toMap());
    }

    await _dbService.logAction(
      uid: adminUid,
      action: "RECORD_ATTENDANCE",
      details: "Recorded attendance for session ${widget.session.title}",
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ الحضور بنجاح")));
    Navigator.pop(context);
  }
}

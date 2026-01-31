import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final String studentId;
  const AttendanceHistoryScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final attendanceRef = FirebaseDatabase.instance.ref().child('attendance');

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref().child('users').child(studentId).get(),
          builder: (context, snapshot) {
            String title = "سجل الحضور";
            if (snapshot.hasData && snapshot.data!.value != null) {
              title = "حضور: ${(snapshot.data!.value as Map)['name']}";
            }
            return Text(title);
          },
        ),
      ),
      body: StreamBuilder(
        stream: attendanceRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("لا يوجد سجل حضور حالياً"));
          }

          Map<dynamic, dynamic> allSessions = snapshot.data!.snapshot.value as Map;
          List<Map<String, dynamic>> records = [];

          allSessions.forEach((sessionId, attendances) {
            if (attendances is Map && attendances.containsKey(studentId)) {
              final data = attendances[studentId];
              records.add({
                'session': sessionId,
                'status': data['status'],
                'timestamp': data['timestamp'],
              });
            }
          });

          if (records.isEmpty) {
            return const Center(child: Text("لا يوجد سجل حضور مسجل لهذا الحساب"));
          }

          records.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final status = record['status'];
              final date = DateTime.fromMillisecondsSinceEpoch(record['timestamp'] ?? 0);

              return FutureBuilder<DataSnapshot>(
                future: FirebaseDatabase.instance.ref().child('sessions').child(record['session']).get(),
                builder: (context, sessionSnap) {
                  String sessionTitle = "جلسة...";
                  if (sessionSnap.hasData && sessionSnap.data!.value != null) {
                    sessionTitle = (sessionSnap.data!.value as Map)['title'] ?? "جلسة غير معروفة";
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: _buildStatusIcon(status),
                      title: Text(sessionTitle, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(date), textAlign: TextAlign.right),
                      trailing: _buildStatusBadge(status),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX();
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'present':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'late':
        icon = Icons.access_time_filled;
        color = Colors.orange;
        break;
      default:
        icon = Icons.cancel;
        color = Colors.red;
    }
    return Icon(icon, color: color, size: 32);
  }

  Widget _buildStatusBadge(String status) {
    String text;
    Color color;
    switch (status) {
      case 'present':
        text = "حاضر";
        color = Colors.green.shade100;
        break;
      case 'late':
        text = "متأخر";
        color = Colors.orange.shade100;
        break;
      default:
        text = "غائب";
        color = Colors.red.shade100;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

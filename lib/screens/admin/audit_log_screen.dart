import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logRef = FirebaseDatabase.instance.ref().child('audit_logs');

    return Scaffold(
      appBar: AppBar(title: const Text("سجل العمليات (Audit Log)")),
      body: StreamBuilder(
        stream: logRef.orderByChild('timestamp').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("لا توجد سجلات حالياً"));
          }

          Map<dynamic, dynamic> logsMap = snapshot.data!.snapshot.value as Map;
          List<MapEntry<dynamic, dynamic>> logs = logsMap.entries.toList();
          logs.sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index].value;
              final date = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] ?? 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.history_edu, color: Colors.blueGrey),
                  title: Text(log['action'] ?? 'عملية غير معروفة', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log['details'] ?? ''),
                      const SizedBox(height: 4),
                      Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX();
            },
          );
        },
      ),
    );
  }
}

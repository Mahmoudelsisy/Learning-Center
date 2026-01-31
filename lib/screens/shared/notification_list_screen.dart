import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatelessWidget {
  final String uid;
  const NotificationListScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("صندوق التنبيهات")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد تنبيهات حالياً"));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final date = DateTime.fromMillisecondsSinceEpoch(notif['timestamp'] ?? 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(notif['title'] ?? 'تنبيه جديد', style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(notif['body'] ?? '', textAlign: TextAlign.right),
                      const SizedBox(height: 4),
                      Text(DateFormat('yyyy-MM-dd HH:mm').format(date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

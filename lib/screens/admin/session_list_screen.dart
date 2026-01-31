import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import 'attendance_screen.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref().child('sessions');

    return Scaffold(
      appBar: AppBar(title: const Text("سجل الحصص")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<SessionModel> sessions = data.entries
                .map((e) => SessionModel.fromMap(e.value, e.key))
                .toList();
            sessions.sort((a, b) => b.date.compareTo(a.date));

            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text(session.title),
                  subtitle: Text("${session.date.toLocal()}".split(' ')[0]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(session: session),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const Center(child: Text("لا توجد حصص مضافة"));
        },
      ),
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة حصة جديدة"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "عنوان الحصة"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                final adminUid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
                final ref = FirebaseDatabase.instance.ref().child('sessions').push();
                final session = SessionModel(
                  id: ref.key!,
                  title: titleController.text,
                  date: DateTime.now(),
                  teacherId: adminUid,
                  groupId: "group_1",
                );
                await ref.set(session.toMap());
                Navigator.pop(context);
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../models/group_model.dart';
import '../../models/subject_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import 'attendance_screen.dart';
import '../../services/pdf_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(context, session);
              },
            );
          }
          return const Center(child: Text("لا توجد حصص مضافة"));
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SessionModel session) {
    return FutureBuilder(
      future: Future.wait([
        FirebaseDatabase.instance.ref().child('groups').child(session.groupId).get(),
        FirebaseDatabase.instance.ref().child('subjects').child(session.subjectId).get(),
      ]),
      builder: (context, AsyncSnapshot<List<DataSnapshot>> snapshot) {
        String groupName = "مجموعة...";
        String subjectName = "مادة...";
        if (snapshot.hasData) {
          groupName = snapshot.data![0].child('name').value as String? ?? "مجموعة غير معروفة";
          subjectName = snapshot.data![1].child('name').value as String? ?? "مادة غير معروفة";
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("$subjectName • $groupName • ${session.date.toLocal()}".split(' ')[0]),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              onPressed: () => PdfService().generateSessionSummary(session, []),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceScreen(session: session)));
            },
          ),
        ).animate().fadeIn().slideX();
      },
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final dbService = DatabaseService();
    String? selectedGroupId;
    String? selectedSubjectId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("إضافة حصة جديدة", textAlign: TextAlign.right),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: "عنوان الحصة"),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<GroupModel>>(
                  stream: dbService.getGroups(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "المجموعة"),
                      items: snapshot.data!.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                      onChanged: (val) => setState(() => selectedGroupId = val),
                    );
                  },
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<SubjectModel>>(
                  stream: dbService.getSubjects(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "المادة"),
                      items: snapshot.data!.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (val) => setState(() => selectedSubjectId = val),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty && selectedGroupId != null && selectedSubjectId != null) {
                    final adminUid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
                    final ref = FirebaseDatabase.instance.ref().child('sessions').push();
                    final session = SessionModel(
                      id: ref.key!,
                      title: titleController.text,
                      date: DateTime.now(),
                      teacherId: adminUid,
                      groupId: selectedGroupId!,
                      subjectId: selectedSubjectId!,
                    );
                    await ref.set(session.toMap());
                    Navigator.pop(context);
                  }
                },
                child: const Text("حفظ"),
              ),
            ],
          );
        },
      ),
    );
  }
}

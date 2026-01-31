import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/database_service.dart';
import '../../models/group_model.dart';
import '../../models/student_profile.dart';

class GroupManagementScreen extends StatefulWidget {
  const GroupManagementScreen({super.key});

  @override
  State<GroupManagementScreen> createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final _dbService = DatabaseService();
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();

  void _addGroup() {
    if (_nameController.text.isNotEmpty) {
      final newGroup = GroupModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        schedule: _scheduleController.text,
      );
      _dbService.createGroup(newGroup);
      _nameController.clear();
      _scheduleController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مجموعة جديدة', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'اسم المجموعة'),
            ),
            TextField(
              controller: _scheduleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'الموعد'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: _addGroup, child: const Text('إضافة')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المجموعات')),
      body: StreamBuilder<List<GroupModel>>(
        stream: _dbService.getGroups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final groups = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(group.schedule),
                  trailing: const Icon(Icons.group_work, color: Colors.teal),
                  onTap: () => _showGroupStudents(group),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showGroupStudents(GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("طلاب مجموعة: ${group.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<StudentProfile>>(
                stream: _dbService.getStudents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final groupStudents = snapshot.data!.where((s) => s.groupIds.contains(group.id)).toList();

                  if (groupStudents.isEmpty) {
                    return const Center(child: Text("لا يوجد طلاب في هذه المجموعة بعد."));
                  }

                  return ListView.builder(
                    itemCount: groupStudents.length,
                    itemBuilder: (context, index) {
                      final student = groupStudents[index];
                      return FutureBuilder<DataSnapshot>(
                        future: FirebaseDatabase.instance.ref().child('users').child(student.uid).get(),
                        builder: (context, userSnap) {
                          if (!userSnap.hasData || userSnap.data!.value == null) return const SizedBox();
                          final name = (userSnap.data!.value as Map)['name'] ?? "مجهول";
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(name, textAlign: TextAlign.right),
                            subtitle: Text(student.tags.join(' • '), textAlign: TextAlign.right),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

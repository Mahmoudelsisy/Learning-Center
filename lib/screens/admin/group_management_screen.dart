import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/group_model.dart';

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
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group.name, textAlign: TextAlign.right),
                subtitle: Text(group.schedule, textAlign: TextAlign.right),
                trailing: const Icon(Icons.group),
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
}

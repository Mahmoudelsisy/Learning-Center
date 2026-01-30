import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/subject_model.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final _dbService = DatabaseService();
  final _nameController = TextEditingController();

  void _addSubject() {
    if (_nameController.text.isNotEmpty) {
      final newSubject = SubjectModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
      );
      _dbService.createSubject(newSubject);
      _nameController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مادة جديدة', textAlign: TextAlign.right),
        content: TextField(
          controller: _nameController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(labelText: 'اسم المادة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: _addSubject, child: const Text('إضافة')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المواد')),
      body: StreamBuilder<List<SubjectModel>>(
        stream: _dbService.getSubjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final subjects = snapshot.data!;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return ListTile(
                title: Text(subject.name, textAlign: TextAlign.right),
                trailing: const Icon(Icons.book),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

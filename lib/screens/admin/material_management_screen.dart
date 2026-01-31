import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/material_model.dart';
import '../../models/subject_model.dart';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MaterialManagementScreen extends StatefulWidget {
  const MaterialManagementScreen({super.key});

  @override
  State<MaterialManagementScreen> createState() => _MaterialManagementScreenState();
}

class _MaterialManagementScreenState extends State<MaterialManagementScreen> {
  final _dbService = DatabaseService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedSubjectId;
  bool _isGenerating = false;

  void _generateAIMaterial() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى إدخال عنوان أولاً")));
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final aiService = AIService();
      final prompt = "قم بتحضير مادة علمية مختصرة وشاملة باللغة العربية لموضوع: ${_titleController.text}. تشمل التعريف وأهم النقاط.";
      final suggestion = await aiService.getChatResponse(prompt);
      setState(() {
        _contentController.text = suggestion;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل توليد المادة")));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _saveMaterial() async {
    if (_titleController.text.isNotEmpty && _selectedSubjectId != null) {
      final ref = FirebaseDatabase.instance.ref().child('materials').push();
      final material = MaterialModel(
        id: ref.key!,
        title: _titleController.text,
        content: _contentController.text,
        subjectId: _selectedSubjectId!,
        createdAt: DateTime.now(),
      );
      await ref.set(material.toMap());
      _titleController.clear();
      _contentController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("إضافة مادة علمية", textAlign: TextAlign.right),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(labelText: "عنوان المادة"),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<SubjectModel>>(
                    stream: _dbService.getSubjects(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "المادة الدراسية"),
                        items: snapshot.data!.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (val) => setState(() => _selectedSubjectId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: "المحتوى العلمي",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: _isGenerating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome, color: Colors.indigo),
                        onPressed: _isGenerating ? null : _generateAIMaterial,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
              ElevatedButton(onPressed: _saveMaterial, child: const Text("حفظ")),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialsRef = FirebaseDatabase.instance.ref().child('materials');

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المواد العلمية")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMaterialDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: materialsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<MaterialModel> materials = data.entries
                .map((e) => MaterialModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(material.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.description, color: Colors.blue),
                    onTap: () => _showMaterialDetail(material),
                  ),
                ).animate().fadeIn().slideY();
              },
            );
          }
          return const Center(child: Text("لا توجد مواد علمية مضافة"));
        },
      ),
    );
  }

  void _showMaterialDetail(MaterialModel material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(material.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Divider(),
              Text(material.content, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

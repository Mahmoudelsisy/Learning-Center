import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/homework_model.dart';
import '../../services/ai_service.dart';

class AddHomework extends StatefulWidget {
  final String sessionId;
  const AddHomework({super.key, required this.sessionId});

  @override
  State<AddHomework> createState() => _AddHomeworkState();
}

class _AddHomeworkState extends State<AddHomework> {
  final _descController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _isGenerating = false;

  void _generateAIHomework() async {
    setState(() => _isGenerating = true);
    try {
      final aiService = AIService();
      final prompt = "اقترح واجب منزلي مميز باللغة العربية لموضوع دراسي. يجب أن يكون الواجب قصيراً وفعالاً.";
      final suggestion = await aiService.getChatResponse(prompt);
      setState(() {
        _descController.text = suggestion;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل توليد الواجب")));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة واجب")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descController,
              maxLines: 5,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: "وصف الواجب",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isGenerating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.psychology, color: Colors.purple),
                  onPressed: _isGenerating ? null : _generateAIHomework,
                  tooltip: "توليد بواسطة الذكاء الاصطناعي",
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("موعد التسليم"),
              subtitle: Text("${_deadline.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final ref = FirebaseDatabase.instance.ref().child('homeworks').push();
                final homework = HomeworkModel(
                  id: ref.key!,
                  sessionId: widget.sessionId,
                  description: _descController.text,
                  deadline: _deadline,
                  createdAt: DateTime.now(),
                );
                await ref.set(homework.toMap());
                Navigator.pop(context);
              },
              child: const Text("حفظ الواجب"),
            )
          ],
        ),
      ),
    );
  }
}

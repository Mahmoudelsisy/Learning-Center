import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/ai_service.dart';

class LessonPlannerScreen extends StatefulWidget {
  const LessonPlannerScreen({super.key});

  @override
  State<LessonPlannerScreen> createState() => _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends State<LessonPlannerScreen> {
  final _topicController = TextEditingController();
  final _levelController = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  void _generatePlan() async {
    if (_topicController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _result = "";
    });

    try {
      final aiService = AIService();
      final plan = await aiService.generateLessonPlan(_topicController.text, _levelController.text);
      setState(() => _result = plan);
    } catch (e) {
      setState(() => _result = "حدث خطأ أثناء تحضير الدرس.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("محضر الدروس الذكي")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: "موضوع الدرس", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _levelController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: "المستوى الدراسي (اختياري)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generatePlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("تحضير الدرس بالذكاء الاصطناعي"),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_result, textAlign: TextAlign.right, style: const TextStyle(fontSize: 16)),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
              ),
          ],
        ),
      ),
    );
  }
}

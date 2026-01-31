import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/evaluation_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EvaluationListScreen extends StatelessWidget {
  final String studentId;
  const EvaluationListScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final evalRef = FirebaseDatabase.instance.ref().child('evaluations').child(studentId);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref().child('users').child(studentId).get(),
          builder: (context, snapshot) {
            String name = "التقييمات";
            if (snapshot.hasData && snapshot.data!.value != null) {
              name = "تقييمات: ${(snapshot.data!.value as Map)['name']}";
            }
            return Text(name);
          },
        ),
      ),
      body: StreamBuilder(
        stream: evalRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<EvaluationModel> evals = data.entries
                .map((e) => EvaluationModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: evals.length,
              itemBuilder: (context, index) {
                final ev = evals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.assessment, color: Colors.green),
                            Text("${ev.date.toLocal()}".split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildScoreItem("الأكاديمي", ev.academicScore, Colors.blue),
                            _buildScoreItem("السلوكي", ev.behavioralScore, Colors.orange),
                          ],
                        ),
                        if (ev.notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text("ملاحظات: ${ev.notes}", textAlign: TextAlign.right, style: const TextStyle(fontStyle: FontStyle.italic)),
                        ]
                      ],
                    ),
                  ),
                ).animate().fadeIn().scale();
              },
            );
          }
          return const Center(child: Text("لا توجد تقييمات بعد"));
        },
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text("$score%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

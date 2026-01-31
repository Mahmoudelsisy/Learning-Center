import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/evaluation_model.dart';

class EvaluationListScreen extends StatelessWidget {
  final String studentId;
  const EvaluationListScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final evalRef = FirebaseDatabase.instance.ref().child('evaluations').child(studentId);

    return Scaffold(
      appBar: AppBar(title: const Text("التقييمات والأداء")),
      body: StreamBuilder(
        stream: evalRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<EvaluationModel> evals = data.entries
                .map((e) => EvaluationModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              itemCount: evals.length,
              itemBuilder: (context, index) {
                final ev = evals[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("التاريخ: ${ev.date.toLocal()}".split(' ')[0]),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("الأكاديمي: ${ev.academicScore}/100"),
                            Text("السلوكي: ${ev.behavioralScore}/100"),
                          ],
                        ),
                        if (ev.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text("ملاحظات: ${ev.notes}"),
                        ]
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("لا توجد تقييمات بعد"));
        },
      ),
    );
  }
}

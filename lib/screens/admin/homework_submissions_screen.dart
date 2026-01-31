import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeworkSubmissionsScreen extends StatelessWidget {
  final String homeworkId;
  final String description;

  const HomeworkSubmissionsScreen({
    super.key,
    required this.homeworkId,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final subRef = FirebaseDatabase.instance.ref().child('submissions').child(homeworkId);

    return Scaffold(
      appBar: AppBar(title: const Text("تسليمات الواجب")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: Text(description, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder(
              stream: subRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("لا توجد تسليمات بعد"));
                }

                Map<dynamic, dynamic> submissions = snapshot.data!.snapshot.value as Map;
                List<MapEntry<dynamic, dynamic>> entries = submissions.entries.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final studentId = entries[index].key;
                    final subData = entries[index].value as Map;

                    return FutureBuilder<DataSnapshot>(
                      future: FirebaseDatabase.instance.ref().child('users').child(studentId).get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData || userSnap.data!.value == null) return const SizedBox();
                        final studentName = (userSnap.data!.value as Map)['name'] ?? "مجهول";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(studentName, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("الحالة: ${subData['status'] == 'completed' ? 'تم التسليم' : 'معلق'}", textAlign: TextAlign.right),
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        ).animate().fadeIn().slideY();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

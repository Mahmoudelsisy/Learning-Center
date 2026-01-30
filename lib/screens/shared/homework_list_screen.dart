import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/homework_model.dart';

class HomeworkListScreen extends StatelessWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeworkRef = FirebaseDatabase.instance.ref().child('homeworks');

    return Scaffold(
      appBar: AppBar(title: const Text("الواجبات المنزلية")),
      body: StreamBuilder(
        stream: homeworkRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<HomeworkModel> homeworks = data.entries
                .map((e) => HomeworkModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              itemCount: homeworks.length,
              itemBuilder: (context, index) {
                final hw = homeworks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(hw.description),
                    subtitle: Text("موعد التسليم: ${hw.deadline.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.assignment),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("لا توجد واجبات حالية"));
        },
      ),
    );
  }
}

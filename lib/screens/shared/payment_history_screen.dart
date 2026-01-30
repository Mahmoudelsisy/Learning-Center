import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String studentId;
  const PaymentHistoryScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final payRef = FirebaseDatabase.instance.ref().child('payments').child(studentId);

    return Scaffold(
      appBar: AppBar(title: const Text("سجل المدفوعات")),
      body: StreamBuilder(
        stream: payRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<MapEntry<dynamic, dynamic>> entries = data.entries.toList();

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final payment = entries[index].value;
                return ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.green),
                  title: Text("المبلغ: ${payment['amount']} ج.م"),
                  subtitle: Text("التاريخ: ${DateTime.fromMillisecondsSinceEpoch(payment['date']).toLocal()}".split(' ')[0]),
                  trailing: Text(payment['status'] == 'paid' ? "تم الدفع" : "معلق"),
                );
              },
            );
          }
          return const Center(child: Text("لا توجد سجلات دفع"));
        },
      ),
    );
  }
}

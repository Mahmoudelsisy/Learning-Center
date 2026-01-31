import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String studentId;
  const PaymentHistoryScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final payRef = FirebaseDatabase.instance.ref().child('payments').child(studentId);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DataSnapshot>(
          future: FirebaseDatabase.instance.ref().child('users').child(studentId).get(),
          builder: (context, snapshot) {
            String name = "المدفوعات";
            if (snapshot.hasData && snapshot.data!.value != null) {
              name = "مدفوعات: ${(snapshot.data!.value as Map)['name']}";
            }
            return Text(name);
          },
        ),
      ),
      body: StreamBuilder(
        stream: payRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map;
            List<MapEntry<dynamic, dynamic>> entries = data.entries.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final payment = entries[index].value;
                final bool isPaid = payment['status'] == 'paid';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.receipt_long, color: isPaid ? Colors.green : Colors.orange),
                    title: Text("المبلغ: ${payment['amount']} ج.م", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("التاريخ: ${DateTime.fromMillisecondsSinceEpoch(payment['date']).toLocal()}".split(' ')[0]),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPaid ? "تم الدفع" : "معلق",
                        style: TextStyle(color: isPaid ? Colors.green.shade900 : Colors.orange.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY();
              },
            );
          }
          return const Center(child: Text("لا توجد سجلات دفع"));
        },
      ),
    );
  }
}

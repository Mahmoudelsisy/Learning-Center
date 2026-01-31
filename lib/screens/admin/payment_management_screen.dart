import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentsRef = FirebaseDatabase.instance.ref().child('users');

    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المالية")),
      body: StreamBuilder(
        stream: studentsRef.orderByChild('role').equalTo('student').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            Map<dynamic, dynamic> studentsMap = snapshot.data!.snapshot.value as Map;
            List<UserModel> students = studentsMap.entries
                .map((e) => UserModel.fromMap(e.value, e.key))
                .toList();

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: const Text("اضغط لتسجيل دفعة"),
                  trailing: const Icon(Icons.payment, color: Colors.green),
                  onTap: () => _showPaymentDialog(context, student),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, UserModel student) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تسجيل دفع: ${student.name}"),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "المبلغ"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                final ref = FirebaseDatabase.instance.ref().child('payments').child(student.uid).push();
                await ref.set({
                  'amount': amount,
                  'date': DateTime.now().millisecondsSinceEpoch,
                  'status': 'paid',
                  'type': 'manual',
                });

                final adminUid = Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
                await DatabaseService().logAction(
                  uid: adminUid,
                  action: "ADD_PAYMENT",
                  details: "Added payment of ${amountController.text} for student ${student.name}",
                );

                Navigator.pop(context);
              }
            },
            child: const Text("تسجيل"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_model.dart';
import '../../models/user_model.dart';
import '../../utils/analytics_engine.dart';
import 'package:firebase_database/firebase_database.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("التحليلات والذكاء")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("حالة المدفوعات"),
            const SizedBox(height: 16),
            _buildPaymentPieChart(dbService),
            const SizedBox(height: 32),
            _buildSectionTitle("توقعات الدخل الشهري"),
            const SizedBox(height: 16),
            _buildIncomeBarChart(dbService),
            const SizedBox(height: 32),
            _buildSectionTitle("تنبيهات أداء الطلاب"),
            const SizedBox(height: 16),
            _buildStudentAlerts(dbService),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo));
  }

  Widget _buildPaymentPieChart(DatabaseService dbService) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<Map<dynamic, dynamic>>(
        stream: dbService.getPayments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          int paid = 0, pending = 0, lateCount = 0;
          snapshot.data!.forEach((_, payments) {
            if (payments is Map) {
              for (var p in payments.values) {
                if (p['status'] == 'paid') {
                  paid++;
                } else if (p['status'] == 'pending') {
                  pending++;
                } else if (p['status'] == 'late') {
                  lateCount++;
                }
              }
            }
          });
          if (paid == 0 && pending == 0 && lateCount == 0) return const Center(child: Text("لا توجد بيانات"));
          return PieChart(PieChartData(sections: [
            PieChartSectionData(value: paid.toDouble(), color: Colors.green, title: 'مدفوع'),
            PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: 'معلق'),
            PieChartSectionData(value: lateCount.toDouble(), color: Colors.red, title: 'متأخر'),
          ]));
        },
      ),
    );
  }

  Widget _buildIncomeBarChart(DatabaseService dbService) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<Map<dynamic, dynamic>>(
        stream: dbService.getPayments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          Map<int, double> monthlyIncome = {};
          snapshot.data!.forEach((_, payments) {
            if (payments is Map) {
              for (var p in payments.values) {
                if (p['status'] == 'paid') {
                  final date = DateTime.fromMillisecondsSinceEpoch(p['date'] ?? 0);
                  monthlyIncome[date.month] = (monthlyIncome[date.month] ?? 0) + (p['amount'] ?? 0).toDouble();
                }
              }
            }
          });
          if (monthlyIncome.isEmpty) return const Center(child: Text("لا توجد بيانات"));
          return BarChart(BarChartData(
            barGroups: monthlyIncome.entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Colors.blue)])).toList(),
            titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(DateFormat('MMM').format(DateTime(2024, v.toInt())))))),
          ));
        },
      ),
    );
  }

  Widget _buildStudentAlerts(DatabaseService dbService) {
    return StreamBuilder<List<UserModel>>(
      stream: FirebaseDatabase.instance.ref().child('users').orderByChild('role').equalTo('student').onValue.map((event) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        if (map == null) return [];
        return map.entries.map((e) => UserModel.fromMap(e.value, e.key)).toList();
      }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final students = snapshot.data!;

        return FutureBuilder<Map<String, List<AttendanceModel>>>(
          future: _fetchAllAttendance(),
          builder: (context, attSnap) {
            if (!attSnap.hasData) return const Center(child: CircularProgressIndicator());
            final attMap = attSnap.data!;

            List<Widget> alerts = [];
            for (var student in students) {
              final history = attMap[student.uid] ?? [];
              final insight = AnalyticsEngine.analyzeAttendance(history);
              if (insight.contains("تنبيه") || insight.contains("ملاحظة")) {
                alerts.add(Card(
                  color: insight.contains("تنبيه") ? Colors.red.shade50 : Colors.orange.shade50,
                  child: ListTile(
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(insight),
                    trailing: Icon(insight.contains("تنبيه") ? Icons.warning : Icons.info, color: insight.contains("تنبيه") ? Colors.red : Colors.orange),
                  ),
                ));
              }
            }
            if (alerts.isEmpty) return const Center(child: Text("جميع الطلاب منتظمون حالياً ✨"));
            return Column(children: alerts);
          },
        );
      },
    );
  }

  Future<Map<String, List<AttendanceModel>>> _fetchAllAttendance() async {
    final ref = FirebaseDatabase.instance.ref().child('attendance');
    final snapshot = await ref.get();
    final Map<String, List<AttendanceModel>> result = {};
    if (snapshot.exists) {
      for (var session in (snapshot.value as Map).values) {
        for (var entry in (session as Map).entries) {
          result.putIfAbsent(entry.key, () => []).add(AttendanceModel.fromMap(entry.value, entry.key));
        }
      }
    }
    return result;
  }
}

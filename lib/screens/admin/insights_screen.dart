import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("التحليلات المالية والأداء")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("توزيع حالات الدفع", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: StreamBuilder<Map<dynamic, dynamic>>(
                stream: dbService.getPayments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  int paid = 0;
                  int pending = 0;
                  int lateCount = 0;

                  snapshot.data!.forEach((studentId, payments) {
                    if (payments is Map) {
                      payments.forEach((paymentId, paymentData) {
                        final status = paymentData['status'];
                        if (status == 'paid') paid++;
                        else if (status == 'pending') pending++;
                        else if (status == 'late') lateCount++;
                      });
                    }
                  });

                  if (paid == 0 && pending == 0 && lateCount == 0) {
                    return const Center(child: Text("لا توجد بيانات دفع متاحة"));
                  }

                  return PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: paid.toDouble(), color: Colors.green, title: 'مدفوع'),
                        PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: 'معلق'),
                        PieChartSectionData(value: lateCount.toDouble(), color: Colors.red, title: 'متأخر'),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text("الدخل الشهري الأخير", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5000, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7000, color: Colors.blue)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6000, color: Colors.blue)]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 8500, color: Colors.blue)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

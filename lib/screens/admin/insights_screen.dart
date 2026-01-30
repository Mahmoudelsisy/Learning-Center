import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text("التحليلات المالية والأداء")),
      body: StreamBuilder<Map<dynamic, dynamic>>(
        stream: dbService.getPayments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final paymentsData = snapshot.data!;
          int paid = 0;
          int pending = 0;
          int lateCount = 0;
          Map<int, double> monthlyIncome = {};

          paymentsData.forEach((studentId, payments) {
            if (payments is Map) {
              payments.forEach((paymentId, paymentData) {
                final status = paymentData['status'];
                final amount = (paymentData['amount'] ?? 0).toDouble();
                final dateMillis = paymentData['date'] ?? 0;
                final date = DateTime.fromMillisecondsSinceEpoch(dateMillis);

                if (status == 'paid') {
                  paid++;
                  monthlyIncome[date.month] = (monthlyIncome[date.month] ?? 0) + amount;
                }
                else if (status == 'pending') pending++;
                else if (status == 'late') lateCount++;
              });
            }
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("توزيع حالات الدفع", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: (paid == 0 && pending == 0 && lateCount == 0)
                    ? const Center(child: Text("لا توجد بيانات دفع متاحة"))
                    : PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(value: paid.toDouble(), color: Colors.green, title: 'مدفوع'),
                            PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: 'معلق'),
                            PieChartSectionData(value: lateCount.toDouble(), color: Colors.red, title: 'متأخر'),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 32),
                const Text("الدخل الشهري", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: monthlyIncome.isEmpty
                    ? const Center(child: Text("لا توجد بيانات دخل حالياً"))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (monthlyIncome.values.isEmpty ? 1000 : monthlyIncome.values.reduce((a, b) => a > b ? a : b) * 1.2),
                          barGroups: monthlyIncome.entries.map((e) =>
                            BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Colors.blue, width: 20)])
                          ).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(DateFormat('MMM').format(DateTime(2024, value.toInt())));
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

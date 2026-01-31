import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'student_management.dart';
import 'session_list_screen.dart';
import '../shared/homework_list_screen.dart';
import 'payment_management_screen.dart';
import 'insights_screen.dart';
import 'group_management_screen.dart';
import 'subject_management_screen.dart';
import 'ai_assistant_screen.dart';
import 'lesson_planner_screen.dart';
import 'material_management_screen.dart';
import 'audit_log_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم المدير"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAISuggestionCard(context).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              children: [
          _buildCard(context, "الطلاب", Icons.people, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentManagement()));
          }),
          _buildCard(context, "الحضور", Icons.calendar_today, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionListScreen()));
          }),
          _buildCard(context, "المالية", Icons.attach_money, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentManagementScreen()));
          }),
          _buildCard(context, "الحصص", Icons.book, Colors.purple, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionListScreen()));
          }),
          _buildCard(context, "الواجبات", Icons.assignment, Colors.blueGrey, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkListScreen()));
          }),
          _buildCard(context, "التحليلات", Icons.insights, Colors.indigo, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()));
          }),
          _buildCard(context, "المجموعات", Icons.group_work, Colors.teal, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupManagementScreen()));
          }),
          _buildCard(context, "المواد", Icons.library_books, Colors.brown, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectManagementScreen()));
          }),
          _buildCard(context, "المساعد الذكي", Icons.psychology, Colors.orangeAccent, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen()));
          }),
          _buildCard(context, "تحضير الدروس", Icons.menu_book, Colors.deepOrange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonPlannerScreen()));
          }),
          _buildCard(context, "المواد العلمية", Icons.science, Colors.blueGrey, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialManagementScreen()));
          }),
          _buildCard(context, "سجل العمليات", Icons.history, Colors.blueGrey, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogScreen()));
          }),
        ],
      ),
    ],
    ),
    ),
    );
  }

  Widget _buildAISuggestionCard(BuildContext context) {
    final suggestions = [
      "بناءً على أداء الطلاب الأخير، يُنصح بالتركيز على مراجعة الجبر في المجموعة أ.",
      "تنبيه: هناك زيادة في نسبة الغياب لمجموعة العلوم يوم الثلاثاء.",
      "اقتراح: الطالب أحمد أحرز تقدماً كبيراً، ربما يحتاج إلى تحدي جديد.",
      "نصيحة: استخدام الوسائل البصرية في درس الفيزياء القادم سيحسن الاستيعاب بنسبة 30%."
    ];
    final randomSuggestion = suggestions[DateTime.now().second % suggestions.length];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("اقتراح الذكاء الاصطناعي", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(width: 8),
              Icon(Icons.lightbulb, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            randomSuggestion,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms).fadeIn();
  }
}

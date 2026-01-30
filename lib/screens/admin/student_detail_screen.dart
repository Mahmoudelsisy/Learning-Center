import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/star_model.dart';
import '../../models/student_profile.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/pdf_service.dart';
import '../../models/group_model.dart';

class StudentDetailScreen extends StatefulWidget {
  final UserModel student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _reasonController = TextEditingController();
  final _amountController = TextEditingController(text: "5");
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _amountController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("بيانات: ${widget.student.name}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("رقم الهاتف"),
                subtitle: Text(widget.student.phone),
              ),
            ),
            const SizedBox(height: 24),
            const Text("تحفيز الطالب (إضافة نجوم)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "عدد النجوم", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                  labelText: "السبب", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _awardStars,
              icon: const Icon(Icons.star, color: Colors.amber),
              label: const Text("منح النجوم"),
              style:
                  ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _exportReport(context),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
              label: const Text("تصدير تقرير PDF"),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showNotificationDialog(context),
              icon: const Icon(Icons.notifications_active, color: Colors.blue),
              label: const Text("إرسال إشعار مباشر"),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 32),
            const Text("تصنيف الطالب (Tags)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                        labelText: "أضف تصنيف (مثل: موهوب، يحتاج متابعة)",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add_circle,
                        size: 40, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child('students_profiles')
                  .child(widget.student.uid)
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final profile = StudentProfile.fromMap(
                      snapshot.data!.snapshot.value as Map, widget.student.uid);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: profile.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  onDeleted: () => _removeTag(profile, tag),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      const Text("المجموعات الدراسية",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildGroupManager(profile),
                    ],
                  );
                }
                return const SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGroupManager(StudentProfile profile) {
    final dbService = DatabaseService();
    return Column(
      children: [
        StreamBuilder<List<GroupModel>>(
          stream: dbService.getGroups(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final allGroups = snapshot.data!;
            final availableGroups = allGroups.where((g) => !profile.groupIds.contains(g.id)).toList();

            return Column(
              children: [
                ...profile.groupIds.map((gid) {
                  final group = allGroups.firstWhere((g) => g.id == gid,
                      orElse: () => GroupModel(id: gid, name: "مجموعة غير معروفة", schedule: ""));
                  return ListTile(
                    title: Text(group.name, textAlign: TextAlign.right),
                    subtitle: Text(group.schedule, textAlign: TextAlign.right),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeGroup(profile, gid),
                    ),
                  );
                }),
                if (availableGroups.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "إضافة إلى مجموعة"),
                    items: availableGroups.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name, textAlign: TextAlign.right),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) _addGroupToProfile(profile, val);
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _addGroupToProfile(StudentProfile profile, String groupId) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid);
    final newGroups = List<String>.from(profile.groupIds)..add(groupId);
    await ref.update({'group_ids': newGroups});
  }

  void _removeGroup(StudentProfile profile, String groupId) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid);
    final newGroups = List<String>.from(profile.groupIds)..remove(groupId);
    await ref.update({'group_ids': newGroups});
  }

  void _addTag() async {
    if (_tagController.text.isEmpty) return;
    final tag = _tagController.text.trim();
    final ref = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid);
    final snapshot = await ref.get();

    StudentProfile profile;
    if (snapshot.exists) {
      profile =
          StudentProfile.fromMap(snapshot.value as Map, widget.student.uid);
    } else {
      profile = StudentProfile(
          uid: widget.student.uid,
          parentId: "",
          groupIds: ["group_1"],
          paymentType: "monthly",
          basePrice: 0);
    }

    if (!profile.tags.contains(tag)) {
      final newTags = List<String>.from(profile.tags)..add(tag);
      await ref.update({'tags': newTags});
    }
    _tagController.clear();
  }

  void _removeTag(StudentProfile profile, String tag) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid);
    final newTags = List<String>.from(profile.tags)..remove(tag);
    await ref.update({'tags': newTags});
  }

  void _awardStars() async {
    if (_reasonController.text.isEmpty || _amountController.text.isEmpty) return;

    final ref = FirebaseDatabase.instance
        .ref()
        .child('stars_history')
        .child(widget.student.uid)
        .push();
    final star = StarModel(
      id: ref.key!,
      studentId: widget.student.uid,
      amount: int.parse(_amountController.text),
      reason: _reasonController.text,
      timestamp: DateTime.now(),
    );

    await ref.set(star.toMap());

    // Update total stars in profile
    final profileRef = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid)
        .child('total_stars');
    final snapshot = await profileRef.get();
    int currentStars = (snapshot.value as int? ?? 0);
    await profileRef.set(currentStars + star.amount);

    final adminUid =
        Provider.of<AuthProvider>(context, listen: false).userModel!.uid;
    await DatabaseService().logAction(
      uid: adminUid,
      action: "AWARD_STARS",
      details:
          "Awarded ${star.amount} stars to ${widget.student.name}. Reason: ${star.reason}",
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("تم منح النجوم بنجاح")));
    _reasonController.clear();
  }

  void _exportReport(BuildContext context) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('students_profiles')
        .child(widget.student.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final profile = StudentProfile.fromMap(snapshot.value as Map, widget.student.uid);
      await PdfService().generateStudentReport(profile, widget.student.name);
    }
  }

  void _showNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إرسال إشعار للطالب"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "العنوان")),
            TextField(controller: bodyController, decoration: const InputDecoration(labelText: "الرسالة")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              // In a real implementation with FCM backend, we would call a Cloud Function or API here.
              // For now, we simulate success and log the action.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال الإشعار بنجاح (محاكاة)")));
              Navigator.pop(context);
            },
            child: const Text("إرسال"),
          ),
        ],
      ),
    );
  }
}

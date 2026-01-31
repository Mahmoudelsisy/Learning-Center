import 'package:firebase_database/firebase_database.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';
import '../models/student_profile.dart';
import '../models/group_model.dart';
import '../models/subject_model.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Sessions
  Future<void> createSession(SessionModel session) async {
    await _dbRef.child('sessions').child(session.id).set(session.toMap());
  }

  Stream<List<SessionModel>> getSessions() {
    return _dbRef.child('sessions').onValue.map((event) {
      Map<dynamic, dynamic>? sessionsMap = event.snapshot.value as Map?;
      if (sessionsMap == null) return [];
      return sessionsMap.entries.map((e) => SessionModel.fromMap(e.value, e.key)).toList();
    });
  }

  // Attendance
  Future<void> recordAttendance(String sessionId, AttendanceModel attendance) async {
    await _dbRef.child('attendance').child(sessionId).child(attendance.studentId).set(attendance.toMap());
  }

  Stream<List<AttendanceModel>> getAttendance(String sessionId) {
    return _dbRef.child('attendance').child(sessionId).onValue.map((event) {
      Map<dynamic, dynamic>? attendanceMap = event.snapshot.value as Map?;
      if (attendanceMap == null) return [];
      return attendanceMap.entries.map((e) => AttendanceModel.fromMap(e.value, e.key)).toList();
    });
  }

  // Students
  Future<void> updateStudentProfile(StudentProfile profile) async {
    await _dbRef.child('students_profiles').child(profile.uid).set(profile.toMap());
  }

  Future<StudentProfile?> getStudentProfile(String uid) async {
    DataSnapshot snapshot = await _dbRef.child('students_profiles').child(uid).get();
    if (snapshot.exists) {
      return StudentProfile.fromMap(snapshot.value as Map, uid);
    }
    return null;
  }

  Stream<List<StudentProfile>> getStudents() {
    return _dbRef.child('students_profiles').onValue.map((event) {
      Map<dynamic, dynamic>? studentsMap = event.snapshot.value as Map?;
      if (studentsMap == null) return [];
      return studentsMap.entries.map((e) => StudentProfile.fromMap(e.value, e.key)).toList();
    });
  }

  Stream<List<StudentProfile>> getChildren(String parentId) {
    return _dbRef.child('students_profiles').orderByChild('parent_id').equalTo(parentId).onValue.map((event) {
      Map<dynamic, dynamic>? studentsMap = event.snapshot.value as Map?;
      if (studentsMap == null) return [];
      return studentsMap.entries.map((e) => StudentProfile.fromMap(e.value, e.key)).toList();
    });
  }

  // Groups
  Future<void> createGroup(GroupModel group) async {
    await _dbRef.child('groups').child(group.id).set(group.toMap());
  }

  Stream<List<GroupModel>> getGroups() {
    return _dbRef.child('groups').onValue.map((event) {
      Map<dynamic, dynamic>? groupsMap = event.snapshot.value as Map?;
      if (groupsMap == null) return [];
      return groupsMap.entries.map((e) => GroupModel.fromMap(e.value, e.key)).toList();
    });
  }

  // Subjects
  Future<void> createSubject(SubjectModel subject) async {
    await _dbRef.child('subjects').child(subject.id).set(subject.toMap());
  }

  Stream<List<SubjectModel>> getSubjects() {
    return _dbRef.child('subjects').onValue.map((event) {
      Map<dynamic, dynamic>? subjectsMap = event.snapshot.value as Map?;
      if (subjectsMap == null) return [];
      return subjectsMap.entries.map((e) => SubjectModel.fromMap(e.value, e.key)).toList();
    });
  }

  // Payments
  Stream<Map<dynamic, dynamic>> getPayments() {
    return _dbRef.child('payments').onValue.map((event) {
      return event.snapshot.value as Map? ?? {};
    });
  }

  // Audit Logs
  Future<void> logAction({
    required String uid,
    required String action,
    required String details,
  }) async {
    final logRef = _dbRef.child('audit_logs').push();
    await logRef.set({
      'uid': uid,
      'action': action,
      'details': details,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

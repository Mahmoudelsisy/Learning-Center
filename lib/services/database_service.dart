import 'package:firebase_database/firebase_database.dart';
import '../models/session_model.dart';
import '../models/attendance_model.dart';
import '../models/student_profile.dart';

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
}

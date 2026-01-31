import '../models/attendance_model.dart';

class AnalyticsEngine {
  static String analyzeAttendance(List<AttendanceModel> history) {
    if (history.isEmpty) return "لا توجد بيانات كافية";

    int absences = history.where((a) => a.status == AttendanceStatus.absent).length;
    double rate = absences / history.length;

    if (rate > 0.3) {
      return "تنبيه: نسبة الغياب مرتفعة جداً (${(rate * 100).toInt()}%)";
    } else if (rate > 0.1) {
      return "ملاحظة: هناك تكرار في الغياب";
    }
    return "الانتظام جيد جداً";
  }
}

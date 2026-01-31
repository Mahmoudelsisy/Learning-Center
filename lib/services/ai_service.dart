import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/student_profile.dart';
import '../models/session_model.dart';

class AIService {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String centerContext = "أنت مساعد ذكي لسنتر تعليمي في الوطن العربي. هدفك مساعدة المدير في التنظيم والطلاب في التعلم.";

  late final GenerativeModel _model;
  ChatSession? _chatSession;

  AIService({String? apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey ?? geminiApiKey,
      systemInstruction: Content.system(centerContext),
    );
  }

  Future<String> getChatResponse(String message) async {
    _chatSession ??= _model.startChat();
    final response = await _chatSession!.sendMessage(Content.text(message));
    return response.text ?? 'عذراً، لم أستطع معالجة طلبك.';
  }

  Future<String> generateLessonPlan(String subject, String level) async {
    final prompt = 'قم بتحضير خطة درس لمادة $subject للمستوى $level باللغة العربية. تشمل الأهداف، الوسائل، والأنشطة.';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'لا يمكن توليد خطة الدرس حالياً.';
  }

  Future<String> analyzeStudentPerformance(StudentProfile student, List<SessionModel> sessions) async {
    final sessionInfo = sessions.map((s) => '${s.title}: ${s.date}').join(', ');
    final prompt = '''
حلل أداء الطالب التالي باللغة العربية بناءً على البيانات المتوفرة:
النجوم الإجمالية: ${student.totalStars}
الشارات الحاصل عليها: ${student.badges.join(', ')}
تاريخ آخر 5 حصص: $sessionInfo
قدم تقريراً تربوياً مختصراً وتوصيات عملية للتحسين.
''';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'لا يمكن تحليل الأداء حالياً.';
  }
}

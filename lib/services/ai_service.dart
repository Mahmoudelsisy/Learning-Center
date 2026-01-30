import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/student_profile.dart';
import '../models/session_model.dart';

class AIService {
  final String apiKey;
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  AIService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<String> getChatResponse(String message) async {
    _chatSession ??= _model.startChat();
    final response = await _chatSession!.sendMessage(Content.text(message));
    return response.text ?? 'عذراً، لم أستطع معالجة طلبك.';
  }

  Future<String> generateLessonPlan(String subject, String level) async {
    final prompt = 'قم بتحضير خطة درس لمادة $subject للمستوى $level باللغة العربية. تشمل الأهداف، الوسائل، والأنشطة.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'لا يمكن توليد خطة الدرس حالياً.';
  }

  Future<String> analyzeStudentPerformance(StudentProfile student, List<SessionModel> sessions) async {
    final sessionInfo = sessions.map((s) => '${s.title}: ${s.date}').join(', ');
    final prompt = '''
حلل أداء الطالب التالي باللغة العربية:
النجوم الإجمالية: ${student.totalStars}
تاريخ الحصص: $sessionInfo
قدم توصيات لتحسين مستواه.
''';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'لا يمكن تحليل الأداء حالياً.';
  }
}

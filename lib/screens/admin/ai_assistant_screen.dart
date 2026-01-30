import 'package:flutter/material.dart';
import '../../services/ai_service.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final AIService _aiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // In a real app, the API key should be managed securely
    _aiService = AIService(apiKey: 'YOUR_GEMINI_API_KEY');
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final response = await _aiService.getChatResponse(userMessage);
      setState(() {
        _messages.add({'role': 'ai', 'text': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'حدث خطأ في الاتصال بالذكاء الاصطناعي.'});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي (Gemini)')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text']!, textAlign: isUser ? TextAlign.right : TextAlign.left),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'اسأل المساعد عن الدروس أو الطلاب...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

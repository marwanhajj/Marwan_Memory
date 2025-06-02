import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isProcessing = false;

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;

  // Add a user message to the chat
  void sendMessage(String text, {bool isVoiceMessage = false}) {
    final userMessage = Message(
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
      isVoiceMessage: isVoiceMessage,
    );
    
    _messages.add(userMessage);
    notifyListeners();
    
    // Process the message with AI
    _processMessageWithAI(text);
  }
  
  // Process the message with AI and get a response
  Future<void> _processMessageWithAI(String text) async {
    _isProcessing = true;
    notifyListeners();
    
    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, this would call an AI API
      // For now, we'll generate a simple response
      final response = _generateSimpleResponse(text);
      
      final aiMessage = Message(
        text: response,
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(aiMessage);
    } catch (e) {
      // Handle error
      final errorMessage = Message(
        text: "عذراً، حدث خطأ أثناء معالجة رسالتك. يرجى المحاولة مرة أخرى.",
        isFromUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(errorMessage);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  // Generate a simple response for demo purposes
  String _generateSimpleResponse(String text) {
    text = text.toLowerCase();
    
    if (text.contains('مرحبا') || text.contains('السلام عليكم') || text.contains('أهلا')) {
      return 'مرحباً! كيف يمكنني مساعدتك اليوم؟';
    } else if (text.contains('اسمك') || text.contains('من أنت')) {
      return 'أنا مساعدك الذكي الصوتي، تم تطويري لمساعدتك والإجابة على أسئلتك.';
    } else if (text.contains('شكرا') || text.contains('شكراً')) {
      return 'العفو! سعيد بمساعدتك.';
    } else if (text.contains('وداعا') || text.contains('مع السلامة')) {
      return 'مع السلامة! أتمنى لك يوماً سعيداً.';
    } else if (text.contains('الطقس') || text.contains('الجو')) {
      return 'عذراً، لا يمكنني الوصول إلى معلومات الطقس حالياً. يمكنك تجربة تطبيق الطقس المحلي للحصول على معلومات دقيقة.';
    } else if (text.contains('الوقت') || text.contains('الساعة')) {
      final now = DateTime.now();
      return 'الوقت الآن هو ${now.hour}:${now.minute.toString().padLeft(2, '0')}.';
    } else if (text.contains('نكتة') || text.contains('اضحكني')) {
      return 'لماذا لا تستطيع الروبوتات قراءة الكتب الإلكترونية؟ لأنها تفقد مكانها عندما تحتاج إلى إعادة شحن بطارياتها! 😄';
    } else if (text.contains('قدرات') || text.contains('تستطيع')) {
      return 'يمكنني مساعدتك في الإجابة على الأسئلة، تقديم معلومات، إجراء محادثات، وتنفيذ مهام بسيطة. أنا في تحسن مستمر لتقديم تجربة أفضل لك.';
    } else {
      return 'شكراً لرسالتك. هل يمكنني مساعدتك بشيء آخر؟';
    }
  }
  
  // Clear all messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}

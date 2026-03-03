import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/database_helper.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final GeminiService _geminiService = GeminiService();

  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  String? _currentConversationId;
  String? _currentSourceLanguage;
  String? _currentTargetLanguage;
  String? _currentSector;
  String? _apiKey;
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  String? get currentConversationId => _currentConversationId;
  String? get currentSourceLanguage => _currentSourceLanguage;
  String? get currentTargetLanguage => _currentTargetLanguage;
  String? get currentSector => _currentSector;
  String? get apiKey => _apiKey;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    _conversations = await _dbHelper.getConversations();
    notifyListeners();
  }

  Future<void> startNewConversation({String? sourceLang, String? targetLang, String? sector, required String apiKey}) async {
    final uuid = const Uuid().v4();
    final newConversation = Conversation(
      id: uuid,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      sourceLanguage: sourceLang ?? 'Türkçe',
      targetLanguage: targetLang ?? 'İngilizce',
      sector: sector ?? '',
    );
    await _dbHelper.insertConversation(newConversation);
    _currentConversationId = uuid;
    _currentSourceLanguage = newConversation.sourceLanguage;
    _currentTargetLanguage = newConversation.targetLanguage;
    _currentSector = newConversation.sector;
    _apiKey = apiKey;
    _currentMessages = [];
    await loadConversations();
    notifyListeners();
  }

  Future<void> loadConversation(String id) async {
    _currentConversationId = id;
    
    // Find the conversation from the loaded list to get its context
    try {
      final conv = _conversations.firstWhere((c) => c.id == id);
      _currentSourceLanguage = conv.sourceLanguage ?? 'Türkçe';
      _currentTargetLanguage = conv.targetLanguage ?? 'İngilizce';
      _currentSector = conv.sector ?? '';
    } catch (e) {
      _currentSourceLanguage = 'Türkçe';
      _currentTargetLanguage = 'İngilizce';
      _currentSector = '';
    }

    _currentMessages = await _dbHelper.getMessages(id);
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
      await _dbHelper.deleteConversation(id);
      if (_currentConversationId == id) {
          _currentConversationId = null;
          _currentMessages = [];
      }
      await loadConversations();
  }

  Future<void> sendMessage(String content, {bool isContextual = true, String direction = 'giden'}) async {
    if (_currentConversationId == null || content.trim().isEmpty || _apiKey == null) return;

    final userMessage = Message(
      conversationId: _currentConversationId!,
      role: 'user',
      content: content,
      direction: direction,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    _currentMessages.add(userMessage);
    await _dbHelper.insertMessage(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      Map<String, String> responseData;
      if (isContextual) {
        // Send last N messages (e.g., 5) for context
        final history = _currentMessages.length > 5 
            ? _currentMessages.sublist(_currentMessages.length - 6, _currentMessages.length - 1) 
            : _currentMessages.sublist(0, _currentMessages.length - 1);
            
        responseData = await _geminiService.translateMessage(
          content,
          history,
          direction: direction,
          sourceLang: _currentSourceLanguage ?? 'Türkçe',
          targetLang: _currentTargetLanguage ?? 'İngilizce',
          sector: _currentSector ?? '',
          apiKey: _apiKey!,
        );
      } else {
        responseData = await _geminiService.translateDirect(
          content,
          direction: direction,
          sourceLang: _currentSourceLanguage ?? 'Türkçe',
          targetLang: _currentTargetLanguage ?? 'İngilizce',
          sector: _currentSector ?? '',
          apiKey: _apiKey!,
        );
      }

      final aiMessage = Message(
        conversationId: _currentConversationId!,
        role: 'model',
        content: responseData["ceviri"] ?? "Cevaplanamadı",
        tip: responseData["ipucu"],
        direction: direction, // The AI response inherently maps to the same transaction direction context
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      _currentMessages.add(aiMessage);
      await _dbHelper.insertMessage(aiMessage);
    } catch (e) {
      final errorMessage = Message(
        conversationId: _currentConversationId!,
        role: 'model',
        content: "Error: \$e",
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      _currentMessages.add(errorMessage);
       await _dbHelper.insertMessage(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

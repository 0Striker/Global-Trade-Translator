class Conversation {
  final String id;
  final int createdAt;
  final String? sourceLanguage;
  final String? targetLanguage;
  final String? sector;

  Conversation({
    required this.id,
    required this.createdAt,
    this.sourceLanguage,
    this.targetLanguage,
    this.sector,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'sector': sector,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      createdAt: map['createdAt'],
      sourceLanguage: map['sourceLanguage'] as String?,
      targetLanguage: map['targetLanguage'] as String?,
      sector: map['sector'] as String?,
    );
  }
}

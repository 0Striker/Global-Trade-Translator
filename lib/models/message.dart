class Message {
  final int? id;
  final String conversationId;
  final String role; // 'user' or 'model'
  final String content;
  final String? tip;
  final String? direction; // 'giden' (I am sending) or 'gelen' (supplier sent)
  final int createdAt;

  Message({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.tip,
    this.direction,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'tip': tip,
      'direction': direction,
      'created_at': createdAt,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      conversationId: map['conversation_id'],
      role: map['role'],
      content: map['content'],
      tip: map['tip'],
      direction: map['direction'],
      createdAt: map['created_at'],
    );
  }
}

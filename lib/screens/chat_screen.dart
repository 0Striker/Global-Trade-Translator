import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedDirection = 'giden'; // 'giden' or 'gelen'

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            final sector = provider.currentSector;
            final isSectorEmpty = sector == null || sector.isEmpty;
            return Text(isSectorEmpty ? 'chat_screen_title'.tr() : 'chat_screen_title_sector'.tr(args: [sector]));
          },
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          
          return Column(
            children: [
              Expanded(
                child: provider.currentMessages.isEmpty
                    ? Center(
                        child: Text(
                          'empty_chat'.tr(),
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: provider.currentMessages.length,
                        itemBuilder: (context, index) {
                          final msg = provider.currentMessages[index];
                          return _buildMessageBubble(msg, provider);
                        },
                      ),
              ),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              _buildInputArea(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, ChatProvider provider) {
    final isUser = msg.role == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isUser ? Colors.blue : Colors.green),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
              minWidth: !isUser ? 200 : 0, // ensure space for the copy button
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  isUser 
                      ? (msg.direction == 'gelen' ? 'original_in'.tr() : 'original_out'.tr())
                      : 'translation_to'.tr(args: [
                          (msg.direction == 'gelen' 
                              ? (provider.currentSourceLanguage ?? 'language_tr'.tr()) 
                              : (provider.currentTargetLanguage ?? 'language_en'.tr()))
                        ]),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isUser 
                        ? (msg.direction == 'gelen' ? Colors.purple[900] : Colors.blue[900])
                        : Colors.green[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.content,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (!isUser && msg.tip != null && msg.tip!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            msg.tip!,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isUser)
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: msg.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('copied'.tr()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    final sourceLang = provider.currentSourceLanguage ?? 'Türkçe';
    final targetLang = provider.currentTargetLanguage ?? 'İngilizce';

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                isSelected: [_selectedDirection == 'giden', _selectedDirection == 'gelen'],
                onPressed: (index) {
                  setState(() {
                    _selectedDirection = index == 0 ? 'giden' : 'gelen';
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: _selectedDirection == 'giden' ? Colors.blue : Colors.purple,
                color: Colors.grey[800],
                constraints: const BoxConstraints(minHeight: 36, minWidth: 120),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('i_write'.tr(args: [sourceLang]), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('they_write'.tr(args: [targetLang, sourceLang]), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: _selectedDirection == 'giden' 
                  ? 'hint_i_write'.tr(args: [sourceLang, targetLang]) 
                  : 'hint_they_write'.tr(args: [targetLang]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          final text = _textController.text;
                          _textController.clear();
                          provider.sendMessage(text, isContextual: true, direction: _selectedDirection);
                        },
                  icon: const Icon(Icons.history, size: 20),
                  label: Text('context_translation'.tr(), style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          final text = _textController.text;
                          _textController.clear();
                          provider.sendMessage(text, isContextual: false, direction: _selectedDirection);
                        },
                  icon: const Icon(Icons.flash_on, size: 20),
                  label: Text('direct_translation'.tr(), style: const TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

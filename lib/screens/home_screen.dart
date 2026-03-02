import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'start_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<ChatProvider>(context, listen: false).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('21 Çeviri 21'),
        backgroundColor: Colors.blue[800],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.forum_outlined, size: 80, color: Colors.grey),
                   const SizedBox(height: 20),
                  const Text(
                    'Henüz konuşma yok.\nYeni bir çeviri başlatmak için tıkla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  _buildNewChatButton(context),
                ],
              ),
            );
          }

          return Column(
            children: [
               Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildNewChatButton(context),
              ),
              const Divider(thickness: 2),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = provider.conversations[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(conv.createdAt);
                    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                        title: Text('Konuşma: $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red),
                           onPressed: () {
                             _showDeleteDialog(context, conv.id);
                           },
                        ),
                        onTap: () async {
                          final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                          await chatProvider.loadConversation(conv.id);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StartMenuScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add, size: 28),
      label: const Text(
        'Yeni Konuşma Başlat',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, String id) {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sil Onayı"),
          content: const Text("Bu konuşmayı silmek istediğinizden emin misiniz?"),
          actions: <Widget>[
            TextButton(
              child: const Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Sil", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await Provider.of<ChatProvider>(context, listen: false).deleteConversation(id);
              },
            ),
          ],
        );
      },
    );
  }
}

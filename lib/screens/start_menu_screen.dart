import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'chat_screen.dart';

class StartMenuScreen extends StatefulWidget {
  const StartMenuScreen({super.key});

  @override
  State<StartMenuScreen> createState() => _StartMenuScreenState();
}

class _StartMenuScreenState extends State<StartMenuScreen> {
  String _sourceLanguageCode = 'tr';
  String _targetLanguageCode = 'en';
  final TextEditingController _sectorController = TextEditingController();

  final List<String> supportedLanguageCodes = [
    'tr',
    'en',
    'ru',
    'zh',
    'hi',
    'ar',
  ];

  @override
  void dispose() {
    _sectorController.dispose();
    super.dispose();
  }

  void _startConversation() async {
    final sector = _sectorController.text.trim();
    if (sector.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir sektör veya konu girin.')),
      );
      return;
    }

    // Call provider to start a new mapped conversation
    final provider = Provider.of<ChatProvider>(context, listen: false);
    await provider.startNewConversation(
      sourceLang: 'language_$_sourceLanguageCode'.tr(),
      targetLang: 'language_$_targetLanguageCode'.tr(),
      sector: sector,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.language, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'new_chat'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('source_lang'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sourceLanguageCode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: supportedLanguageCodes.map((code) {
                        return DropdownMenuItem(value: code, child: Text('language_$code'.tr()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _sourceLanguageCode = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('target_lang'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _targetLanguageCode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: supportedLanguageCodes.map((code) {
                        return DropdownMenuItem(value: code, child: Text('language_$code'.tr()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _targetLanguageCode = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('sector_label'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _sectorController,
                      decoration: InputDecoration(
                        hintText: 'sector_hint'.tr(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('sector_info'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startConversation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('start_chat'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

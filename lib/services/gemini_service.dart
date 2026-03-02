import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class GeminiService {
  // TODO: Replace with actual Google Gemini API Key
  static const String _apiKey = 'AIzaSyBeYYeJiBKVRWJ74lYm553WGCAB04GtDwA';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  String _buildSystemInstruction(String sourceLang, String targetLang, String sector) {
    String sectorInfo = sector.trim().isNotEmpty ? "Özellikle '$sector' sektörü terminolojisine ve dinamiklerine son derece hakimsin." : "";
    return '''
Sen küresel tedarikçilerle ticaret iletişimi için $sourceLang ve $targetLang arasında profesyonel bir ithalat-ihracat çevirmenisin.
Mesajları net, basit ve anlaşılır bir iş diline çevir.
$sectorInfo
Teknik ticaret terimlerini (FOB, EXW, MOQ, CIF vb.) kesinlikle koru.

ÖNEMLİ İPUCU KURALI: 
Kullanıcıya sadece spesifik mesaja yönelik, işine yarayacak BİR ipucu ver. 
Eğer metinde spesifik bir ticaret terimi (örneğin EXW, FOB) geçiyorsa, bunun alıcı için ne anlama geldiğini veya risklerini (örneğin: "EXW'de nakliye/gümrük size aittir...") kısaca açıkla.
Genel geçer, her mesaja uyan tavsiyeler (örneğin: "şartları mutlaka netleştirin") VERME! İpucu kısa, pratik ve taktiksel olsun. Eğer ürün fiyatı içeriyorsa piyasa ortalamasına göre pazarlık opsiyonu belirt ya da piyasa fiyatı altındaysa bunu belirt. Eğer verilecek spesifik bir ipucu yoksa boş bırak.

SADECE AŞAĞIDAKİ JSON FORMATINDA YANIT VER. BAŞKA HİÇBİR TEXT YAZMA:
{
  "ceviri": "Çevrilen metin buraya",
  "ipucu": "💡 İpucu: Bu spesifik duruma özel taktik veya terim açıklaması (gerekmiyorsa boş bırak)"
}
''';
  }

  Future<Map<String, String>> translateMessage(
      String currentMessage, 
      List<Message> history, 
      {String? direction,
      required String sourceLang,
      required String targetLang,
      required String sector}) async {
    try {
      final List<Map<String, dynamic>> contents = [];

      // Add context history (if any)
      for (var msg in history) {
        String historyPrefix = "";
        if (msg.direction == 'giden') historyPrefix = "[Ben Gönderdim]: ";
        if (msg.direction == 'gelen') historyPrefix = "[Tedarikçi Gönderdi]: ";

        contents.add({
          "role": msg.role,
          "parts": [
            {"text": "$historyPrefix${msg.content}"}
          ]
        });
      }

      // Add current message
      String promptPrefix = "";
      if (direction == 'giden') {
         promptPrefix = "Bu mesajı BEN ($sourceLang konuşan İthalatçı/Alıcı) karşı tarafa yazıyorum. Lütfen profesyonel iş iletişimine uygun $targetLang diline çevir:\n";
      } else if (direction == 'gelen') {
         promptPrefix = "Bu mesaj karşı taraftan ($targetLang konuşan Tedarikçi/Satıcı) BANA geldi. Lütfen anlaşılır, pürüzsüz bir $sourceLang diline çevir:\n";
      }

      final dynamicSystemInstruction = _buildSystemInstruction(sourceLang, targetLang, sector);

      contents.add({
        "role": "user",
        "parts": [
          {"text": "$dynamicSystemInstruction\n\n$promptPrefix\n$currentMessage"}
        ]
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": contents,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final jsonString = data['candidates'][0]['content']['parts'][0]['text'];
          try {
             // Remove markdown code blocks if the AI returns them (e.g. ```json ... ```)
             final cleanedJsonString = jsonString.replaceAll(RegExp(r'```json|```'), '').trim();
             final parsedJson = jsonDecode(cleanedJsonString);
             return {
               "ceviri": parsedJson["ceviri"] ?? "Çeviri hatası",
               "ipucu": parsedJson["ipucu"] ?? "",
             };
          } catch(e) {
             return {
                "ceviri": jsonString, // Fallback to raw text if JSON parsing fails
                "ipucu": "",
             };
          }

        } else {
             return { "ceviri": "Error: Unexpected response format from API.", "ipucu": "" };
        }
      } else {
        return { "ceviri": "API Error: ${response.statusCode}", "ipucu": "" };
      }
    } catch (e) {
      return { "ceviri": "Translation failed: $e", "ipucu": "" };
    }
  }

  Future<Map<String, String>> translateDirect(String currentMessage, {String? direction, required String sourceLang, required String targetLang, required String sector}) async {
    return translateMessage(currentMessage, [], direction: direction, sourceLang: sourceLang, targetLang: targetLang, sector: sector); // Empty history for direct
  }
}

<div align="center">

# 🌍 Global Trade Translator
**AI-Powered Context-Aware Translation Tool for International Trade**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](#)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white)](#)
[![Gemini](https://img.shields.io/badge/Gemini-AI-orange)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Break down language barriers in international trade with specialized AI that understands Incoterms, industry jargon, and negotiation tactics.*

</div>

## ✨ Features

- **🌐 Multi-Language Support**: Translate seamlessly between English, Turkish, Chinese, Russian, Hindi, and Arabic.
- **🏭 Sector-Specific Context**: Input your specific industry (e.g., *Textiles, Sports Equipment, Electronics*), and the AI adapts its vocabulary to match your sector's jargon.
- **🧠 Intelligent Negotiation Tips**: Doesn't just translate! The AI analyzes incoming and outgoing messages to offer strategic negotiation tips.
- **📦 Incoterm Explanations**: Automatically detects terms like `FOB`, `EXW`, or `CIF` and explains their cost and risk implications (e.g., *"Warning: EXW means you bear the delivery costs"*).
- **🗂️ Conversation History**: Saves your negotiation drafts locally using SQLite.
- **💻 Cross-Platform**: Android, iOS, Windows, and macOS ready!

## 🚀 Quick Start (Windows)

You don't need to compile the code if you're on Windows. Just grab the latest `.exe` release!

1. Go to the [Releases](../../releases) page.
2. Download `GlobalTradeTranslator-Windows.zip`.
3. Extract and run `Global Trade Translator.exe`.

## 🛠️ Development & Build from Source

Ensure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

```bash
# Clone the repository
git clone https://github.com/yourusername/global-trade-translator.git

# Navigate to the directory
cd global-trade-translator

# Install dependencies
flutter pub get

# Run on your desktop or emulator
flutter run
```

### 🔑 Setting up the API Key (Gemini AI)
Currently, this app utilizes Google's **Gemini 2.5 Flash** model. 
1. Open `lib/services/gemini_service.dart`.
2. Replace the `_apiKey` variable with your own from Google AI Studio.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](../../issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🌟 Support
If you find this project helpful for your import/export business, please give it a ⭐️!

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.

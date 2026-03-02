import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const AITranslateApp(),
    ),
  );
}

class AITranslateApp extends StatelessWidget {
  const AITranslateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '21 Çeviri 21',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Default standard font
      ),
      home: const HomeScreen(),
    );
  }
}

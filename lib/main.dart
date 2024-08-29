import 'package:flutter/material.dart';
import 'package:realtime_chatapp/views/chat_page.dart';
import 'package:realtime_chatapp/views/home.dart';
import 'package:realtime_chatapp/views/phone_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const PhoneLoginState(),
        // '/': (context) => const HomePage(),
        "/home": (context) => const HomePage(),
        "/chat":(context) => const ChatPage(),
      },
    );
  }
}

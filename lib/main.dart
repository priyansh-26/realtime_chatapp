import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/controllers/local_saved_data.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';
import 'package:realtime_chatapp/views/chat_page.dart';
import 'package:realtime_chatapp/views/home.dart';
import 'package:realtime_chatapp/views/phone_login.dart';
import 'package:realtime_chatapp/views/profile.dart';
import 'package:realtime_chatapp/views/search_users.dart';
import 'package:realtime_chatapp/views/update_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalSavedData.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        routes: {
          '/login': (context) => const PhoneLoginState(),
          '/': (context) => const CheckUserSession(),
          "/home": (context) => const HomePage(),
          "/chat": (context) => const ChatPage(),
          "/profile": (context) => const ProfilePage(),
          "/update": (context) => const UpdateProfile(),
          "/search": (context) => const SearchUsers(),
        },
      ),
    );
  }
}

class CheckUserSession extends StatefulWidget {
  const CheckUserSession({super.key});

  @override
  State<CheckUserSession> createState() => _CheckUserSessionState();
}

class _CheckUserSessionState extends State<CheckUserSession> {
  @override
  void initState() {
    // TODO: implement initState
    checkSessions().then((value) => {
          if (value)
            {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/update", (route) => false,arguments: {"title":"add"})
            }
          else
            {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/login", (route) => false)
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

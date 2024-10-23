// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_null_comparison

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/controllers/fcm_controllers.dart';
import 'package:realtime_chatapp/controllers/local_saved_data.dart';
import 'package:realtime_chatapp/firebase_options.dart';
import 'package:realtime_chatapp/providers/chat_provider.dart';
import 'package:realtime_chatapp/providers/group_message_provider.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';
import 'package:realtime_chatapp/views/chat_page.dart';
import 'package:realtime_chatapp/views/create_or_update_group.dart';
import 'package:realtime_chatapp/views/group_chat_page.dart';
import 'package:realtime_chatapp/views/home.dart';
import 'package:realtime_chatapp/views/invite_members.dart';
import 'package:realtime_chatapp/views/phone_login.dart';
import 'package:realtime_chatapp/views/profile.dart';
import 'package:realtime_chatapp/views/search_users.dart';
import 'package:realtime_chatapp/views/update_profile.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

final navigatorKey = GlobalKey<NavigatorState>();
// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId = Provider.of<UserDataProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detched");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }
}

void main() async {
  //if error occurs change here
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      // Handle the duplicate app error if necessary.
    } else {
      rethrow; // Rethrow other exceptions.
    }
  }
  await LocalSavedData.init();
  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  await PushNotifications.localNotiInit();
  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/home", arguments: message);
    }
  });

// to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        "/home",
      );
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GroupMessageProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
          "/modify_group": (context) => const CreateOrUpdateGroup(),
          "/read_group_message": (context) => const GroupChatPage(),
          "/invite_members":(context)=>const InviteMembers(),
          // "/group_detail":(context)=>const GroupDetails(),
          // "/explore_groups":(context)=>const ExploreGroups()
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
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });

    // TODO: implement initState
    checkSessions().then((value) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;
      print("username :$userName");
      if (value) {
        if (userName != null && userName != "") {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, "/update", (route) => false,
              arguments: {"title": "add"});
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
    super.initState();
    // initialization();
  }

  // void initialization() async {
  //   print("pausing");
  //   await Future.delayed(Duration(seconds: 2));
  //   print("resuming");
  //   FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        //to add splash screen add inside this
        body: Center(child: CircularProgressIndicator()),
        // body: Column(
        //   children: [
        //     SizedBox(
        //       height: 150,
        //     ),
        //     Center(child: Image(image: AssetImage("assets/register.png"))),
        //     SizedBox(height: 170),
        //     Text(
        //       "Groupie",
        //       style: GoogleFonts.acme(
        //         fontSize: 40,
        //         fontWeight: FontWeight.bold,
        //         color: Color.fromARGB(255, 69, 66, 66),
        //       ),
        //     ),
        //   ],
        // ),
      
    );
  }
}

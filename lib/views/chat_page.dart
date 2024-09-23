// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/chat_message.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List messages = [
    MessageModel(
      message: "Hello",
      sender: "101",
      receiver: "202",
      timestamp: DateTime(2024, 1, 12),
      isSeenByReceiver: true,
    ),
    MessageModel(
      message: "Hola",
      sender: "202",
      receiver: "101",
      timestamp: DateTime(2024, 1, 12),
      isSeenByReceiver: false,
    ),
    MessageModel(
      message: "Hola",
      sender: "202",
      receiver: "101",
      timestamp: DateTime(2024, 1, 12),
      isSeenByReceiver: false,
      isImage: true,
    ),
    MessageModel(
      message: "how are you",
      sender: "101",
      receiver: "202",
      timestamp: DateTime(2024, 1, 12),
      isSeenByReceiver: false,
    )
  ];
  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];
        return Scaffold(
          appBar: AppBar(
            leadingWidth: 40,
            backgroundColor: kBackgroundColor,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: receiver.profilePic == "" ||
                          receiver.profilePic == null
                      ? Image(
                          image: AssetImage("assets/user.png"),
                        ).image
                      : CachedNetworkImageProvider(
                          "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${receiver.profilePic}/view?project=662e8e5c002f2d77a17c&mode=admin"),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiver.name!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      receiver.isOnline == true ? "Online" : "Offline",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    itemBuilder: (context, index) => ChatMessage(
                      msg: messages[index],
                      currentUser: "101",
                      isImage: true,
                    ),
                    itemCount: messages.length,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Message"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send_rounded),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

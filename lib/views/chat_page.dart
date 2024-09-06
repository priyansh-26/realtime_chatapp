import 'package:flutter/material.dart';
import 'package:realtime_chatapp/constants/chat_message.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/models/message_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        backgroundColor: kBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
                backgroundImage: const Image(
              image: AssetImage("assets/user.png"),
            ).image),
            const SizedBox(
              width: 10,
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Other User",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Online",
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
  }
}

// ignore_for_file: prefer_const_constructors, avoid_print, avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/chat_message.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/providers/chat_provider.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  TextEditingController editmessageController = TextEditingController();

  late String currentUserId;
  late String currentUserName;
  FilePickerResult? _filePickerResult;

  // List messages = [
  //   MessageModel(
  //     message: "Hello",
  //     sender: "101",
  //     receiver: "202",
  //     timestamp: DateTime(2024, 1, 12),
  //     isSeenByReceiver: true,
  //   ),
  //   MessageModel(
  //     message: "Hola",
  //     sender: "202",
  //     receiver: "101",
  //     timestamp: DateTime(2024, 1, 12),
  //     isSeenByReceiver: false,
  //   ),
  //   MessageModel(
  //     message: "Hola",
  //     sender: "202",
  //     receiver: "101",
  //     timestamp: DateTime(2024, 1, 12),
  //     isSeenByReceiver: false,
  //     isImage: true,
  //   ),
  //   MessageModel(
  //     message: "how are you",
  //     sender: "101",
  //     receiver: "202",
  //     timestamp: DateTime(2024, 1, 12),
  //     isSeenByReceiver: false,
  //   )
  // ];

  @override
  void initState() {
    currentUserId =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    currentUserName =
        Provider.of<UserDataProvider>(context, listen: false).getUserName;

    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserId);

    super.initState();
  }

  // to open file picker
  void _openFilePicker(UserData receiver) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    setState(() {
      _filePickerResult = result;
      uploadAllImage(receiver);
    });
  }

  // to upload files to our storage bucket and our database
  void uploadAllImage(UserData receiver) async {
    if (_filePickerResult != null) {
      _filePickerResult!.paths.forEach((path) {
        if (path != null) {
          var file = File(path);
          final fileBytes = file.readAsBytesSync();
          final inputfile = InputFile.fromBytes(
              bytes: fileBytes, filename: file.path.split("/").last);

          // saving image to our storage bucket
          saveImageToBucket(image: inputfile).then((imageId) {
            if (imageId != null) {
              createNewChat(
                message: imageId,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: true,
                // isGroupInvite: false,
              ).then((value) {
                if (value) {
                  Provider.of<ChatProvider>(context, listen: false).addMessage(
                      MessageModel(
                        // isGroupInvite: false,
                        message: imageId,
                        sender: currentUserId,
                        receiver: receiver.userId,
                        timestamp: DateTime.now(),
                        isSeenByReceiver: false,
                        isImage: true,
                      ),
                      currentUserId,
                      [UserData(phone: "", userId: currentUserId), receiver]);
                  sendNotificationtoOtherUser(
                      notificationTitle: '$currentUserName sent you an image',
                      notificationBody: "check it out.",
                      deviceToken: receiver.deviceToken!);
                }
              });
            }
          });
        }
      });
    } else {
      print("file pick cancelled by user");
    }
  }

  // to send simple text message
  void _sendMessage({required UserData receiver}) {
    if (messageController.text.isNotEmpty) {
      setState(() {
        createNewChat(
                message: messageController.text,
                senderId: currentUserId,
                receiverId: receiver.userId,
                isImage: false)
            .then((value) {
          if (value) {
            Provider.of<ChatProvider>(context, listen: false).addMessage(
                MessageModel(
                    message: messageController.text,
                    sender: currentUserId,
                    receiver: receiver.userId,
                    timestamp: DateTime.now(),
                    isSeenByReceiver: false),
                currentUserId,
                [UserData(phone: "", userId: currentUserId), receiver]);
            sendNotificationtoOtherUser(
                notificationTitle: '$currentUserName sent you a message',
                notificationBody: messageController.text,
                deviceToken: receiver.deviceToken!);
            messageController.clear();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserData receiver = ModalRoute.of(context)!.settings.arguments as UserData;
    return Consumer<ChatProvider>(
      builder: (context, value, child) {
        final userAndOtherChats = value.getAllChats[receiver.userId] ?? [];

        bool? otherUserOnline = userAndOtherChats.isNotEmpty
            ? userAndOtherChats[0].users[0].userId == receiver.userId
                ? userAndOtherChats[0].users[0].isOnline
                : userAndOtherChats[0].users[1].isOnline
            : false;
        List<String> receiverMsgList = [];
        for (var chat in userAndOtherChats) {
          if (chat.message.receiver == currentUserId) {
            if (chat.message.isSeenByReceiver == false) {
              receiverMsgList.add(chat.message.messageId!);
            }
          }
        }
        updateIsSeen(chatsIds: receiverMsgList);
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
                          "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${receiver.profilePic}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin"),
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
                      otherUserOnline == true ? "Online" : "Offline",
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
                    reverse: true,
                    itemBuilder: (context, index) {
                      final msg = userAndOtherChats[
                              userAndOtherChats.length - 1 - index]
                          .message;
                      print(userAndOtherChats.length);
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: msg.isImage == true
                                        ? Text(msg.sender == currentUserId
                                            ? "Choose what you want to do with this image."
                                            : "This image cant be modified")
                                        : Text(
                                            "${msg.message.length > 20 ? msg.message.substring(0, 20) : msg.message} ..."),
                                    content: msg.isImage == true
                                        ? Text(msg.sender == currentUserId
                                            ? "Delete this image"
                                            : "This image cant be deleted")
                                        : Text(msg.sender == currentUserId
                                            ? "Chosse what you want to do with this message."
                                            : "This message cant be deleted"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel")),
                                      msg.sender == currentUserId
                                          ? TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                editmessageController.text =
                                                    msg.message;
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text("Edit Message"),
                                                    content: TextFormField(
                                                      controller:
                                                          editmessageController,
                                                      maxLines: 1,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          editChat(
                                                              chatId: msg
                                                                  .messageId!,
                                                              message:
                                                                  editmessageController
                                                                      .text);
                                                          Navigator.pop(
                                                              context);
                                                          editmessageController
                                                              .text = "";
                                                        },
                                                        child: Text('Ok'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Text("Edit"))
                                          : SizedBox(),
                                      msg.sender == currentUserId
                                          ? TextButton(
                                              onPressed: () {
                                                Provider.of<ChatProvider>(
                                                        context,
                                                        listen: false)
                                                    .deleteMessage(
                                                  msg,
                                                  currentUserId,
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: Text("Delete"))
                                          : SizedBox(),
                                    ],
                                  ));
                        },
                        child: ChatMessage(
                            msg: msg,
                            currentUser: currentUserId,
                            isImage: msg.isImage ?? false),
                      );
                    },
                    itemCount: userAndOtherChats.length,
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
                    child: TextField(
                      onSubmitted: (value) {
                        _sendMessage(receiver: receiver);
                      },
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Message"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _openFilePicker(receiver);
                    },
                    icon: Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage(receiver: receiver);
                    },
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

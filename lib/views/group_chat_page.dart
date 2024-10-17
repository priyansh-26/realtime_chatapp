// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/constants/group_chat_message.dart';
import 'package:realtime_chatapp/constants/memberCalculate.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/models/group_message_model.dart';
import 'package:realtime_chatapp/models/group_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/providers/group_message_provider.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _editMessageController = TextEditingController();
  late String currentUser = "";
  @override
  void initState() {
    currentUser =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    super.initState();
  }

  // to open file picker
  // void _openFilePicker(GroupModel groupData) async {
  //   FilePickerResult? result = await FilePicker.platform
  //       .pickFiles(allowMultiple: true, type: FileType.image);

  //   setState(() {
  //     _filePickerResult = result;
  //     uploadAllImage(groupData);
  //   });
  // }

  // // to upload files to our storage bucket and our database
  // void uploadAllImage(GroupModel groupData) async {
  //   if (_filePickerResult != null) {
  //     _filePickerResult!.paths.forEach((path) {
  //       if (path != null) {
  //         var file = File(path);
  //         final fileBytes = file.readAsBytesSync();
  //         final inputfile = InputFile.fromBytes(
  //             bytes: fileBytes, filename: file.path.split("/").last);

  //         // saving image to our storage bucket
  //         saveImageToBucket(image: inputfile).then((imageId) {
  //           if (imageId != null) {
  //             sendGroupMessage(
  //                 groupId: groupData.groupId,
  //                 message: imageId,
  //                 senderId: currentUser,
  //                 isImage: true);
  //             List<String> userTokens = [];

  //             for (var i = 0; i < groupData.userData.length; i++) {
  //               if (groupData.userData[i].userId != currentUser) {
  //                 userTokens.add(groupData.userData[i].deviceToken ?? "");
  //               }
  //             }
  //             print("users token are $userTokens");
  //             //  sendMultipleNotificationtoOtherUser(notificationTitle: "Received an image in ${groupData.groupName}", notificationBody: '${currentUserName}: Sent and image', deviceToken:userTokens );
  //           }
  //         });
  //       }
  //     });
  //   } else {
  //     print("file pick cancelled by user");
  //   }
  // }

  void _sendGroupMessage(
      {required String groupId,
      required GroupModel groupData,
      required String message,
      required String senderId,
      bool? isImage}) async {
    await sendGroupMessage(
            groupId: groupId,
            message: message,
            isImage: isImage,
            senderId: senderId)
        .then((value) {
      if (value) {
        List<String> userTokens = [];

        for (var i = 0; i < groupData.userData.length; i++) {
          if (groupData.userData[i].userId != currentUser) {
            userTokens.add(groupData.userData[i].deviceToken ?? "");
          }
        }
        print("users token are $userTokens");
        // sendMultipleNotificationtoOtherUser(notificationTitle: "Received a message in ${groupData.groupName}", notificationBody: '${currentUserName}: ${_messageController.text}', deviceToken:userTokens );
        Provider.of<GroupMessageProvider>(context, listen: false)
            .addGroupMessage(
                groupId: groupId,
                msg: GroupMessageModel(
                    messageId: "",
                    groupId: groupId,
                    message: message,
                    senderId: senderId,
                    timestamp: DateTime.now(),
                    userData: [UserData(phone: "", userId: senderId)],
                    isImage: isImage));
      }
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GroupModel groupData =
        ModalRoute.of(context)!.settings.arguments as GroupModel;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        backgroundColor: kBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: groupData.image == "" || groupData.image == null
                  ? Image(
                      image: AssetImage("assets/user.png"),
                    ).image
                  : CachedNetworkImageProvider(
                      "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${groupData.image}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin"),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupData.groupName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  memCal(groupData.members.length),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (groupData.isPublic || groupData.admin == currentUser)
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.group_add_outlined),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Invite Members"),
                    ],
                  ),
                ),
              if (groupData.admin == currentUser)
                PopupMenuItem<String>(
                  onTap: () =>
                      Navigator.pushNamed(context, "/modify_group", arguments: {
                    "id": groupData.groupId,
                    "name": groupData.groupName,
                    "desc": groupData.groupDesc,
                    "image": groupData.image,
                  }),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Edit Group"),
                    ],
                  ),
                ),
              if (groupData.admin != currentUser)
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app_rounded),
                      SizedBox(
                        width: 8,
                      ),
                      Text("Exit Group"),
                    ],
                  ),
                ),
            ],
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(children: [
        Expanded(child: Consumer<GroupMessageProvider>(
          builder: (context, value, child) {
            Map<String, List<GroupMessageModel>> allGroupMessages =
                value.getGroupMessages;
            List<GroupMessageModel> thisGroupMsg =
                allGroupMessages[groupData.groupId] ?? [];
            List<GroupMessageModel> reverseMsg = thisGroupMsg.reversed.toList();

            return ListView.builder(
                reverse: true,
                itemBuilder: (context, index) => GroupChatMessage(
                    msg: reverseMsg[index],
                    currentUser: currentUser,
                    isImage: reverseMsg[index].isImage ?? false),
                itemCount: reverseMsg.length);
          },
        )),
        Container(
          margin: EdgeInsets.all(6),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: kSecondaryColor, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  // _sendMessage(receiver: receiver);
                },
                controller: _messageController,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: "Message"),
              ),
            ),
            IconButton(
              onPressed: () {
                // _openFilePicker(receiver);
              },
              icon: Icon(Icons.image),
            ),
            IconButton(
              onPressed: () {
                _sendGroupMessage(
                    groupData: groupData,
                    groupId: groupData.groupId,
                    message: _messageController.text,
                    senderId: currentUser);
              },
              icon: Icon(Icons.send_rounded),
            ),
          ]),
        ),
      ]),
    );
  }
}

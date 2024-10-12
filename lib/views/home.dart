// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_const_literals_to_create_immutables, unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/constants/formate_data.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/controllers/fcm_controllers.dart';
import 'package:realtime_chatapp/models/chat_data_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/providers/chat_provider.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentUserid = "";

  @override
  void initState() {
    currentUserid =
        Provider.of<UserDataProvider>(context, listen: false).getUserId;
    Provider.of<ChatProvider>(context, listen: false).loadChats(currentUserid);
    PushNotifications.getDeviceToken();
    updateOnlineStatus(status: true, userId: currentUserid);
    subscribeToRealtime(userId: currentUserid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Chats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile"),
              child:
                  Consumer<UserDataProvider>(builder: (context, value, child) {
                return CircleAvatar(
                    backgroundImage: value.getUserProfile != null ||
                            value.getUserProfile != ""
                        ? CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${value.getUserProfile}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin")
                        : Image(
                            image: AssetImage("assets/user.png"),
                          ).image);
              }),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(
              text: "Direct Messages",
            ),
            Tab(
              text: "Group Messages",
            ),
          ]),
        ),
        body: TabBarView(children: [
          Consumer<ChatProvider>(
            builder: (context, value, child) {
              if (value.getAllChats.isEmpty) {
                return Center(
                  child: Text("No chats to show"),
                );
              } else {
                List otherUsers = value.getAllChats.keys.toList();
                return ListView.builder(
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      List<ChatDataModel> chatData =
                          value.getAllChats[otherUsers[index]]!;

                      int totalChats = chatData.length;
                      UserData otherUser =
                          chatData[0].users[0].userId == currentUserid
                              ? chatData[0].users[1]
                              : chatData[0].users[0];

                      int unreadMsg = 0;

                      chatData.fold(
                        unreadMsg,
                        (previousValue, element) {
                          if (element.message.isSeenByReceiver == false) {
                            unreadMsg++;
                          }
                          return unreadMsg;
                        },
                      );
                      return ListTile(
                        onTap: () => Navigator.pushNamed(context, "/chat",
                            arguments: otherUser),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                                backgroundImage: otherUser.profilePic == "" ||
                                        otherUser.profilePic == null
                                    ? Image(
                                        image: AssetImage("assets/user.png"),
                                      ).image
                                    : CachedNetworkImageProvider(
                                        "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${otherUser.profilePic}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin")),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 6,
                                backgroundColor: otherUser.isOnline == true
                                    ? Colors.green
                                    : Colors.grey.shade600,
                              ),
                            )
                          ],
                        ),
                        title: Text(otherUser.name!),
                        subtitle: Text(
                          "${chatData[totalChats - 1].message.sender == currentUserid ? "You : " : ""}${chatData[totalChats - 1].message.isImage == true ? "Sent an image" : chatData[totalChats - 1].message.message}",
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              chatData[totalChats - 1].message.sender !=
                                      currentUserid
                                  ? unreadMsg != 0
                                      ? CircleAvatar(
                                          backgroundColor: kPrimaryColor,
                                          radius: 12,
                                          child: Text(
                                            unreadMsg.toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white),
                                          ))
                                      : SizedBox()
                                  : SizedBox(),
                              SizedBox(
                                height: 8,
                              ),
                              Text(formatDate(
                                  chatData[totalChats - 1].message.timestamp))
                            ]),
                      );
                    });
              }
            },
          ),
          Text("Group Messages")
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, "/search");
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/models/group_model.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
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
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
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
              PopupMenuItem<String>(
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
    );
  }
}

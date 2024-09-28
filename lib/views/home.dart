// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Consumer<UserDataProvider>(builder: (context, value, child) {
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
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => ListTile(
          onTap: () => Navigator.pushNamed(context, "/chat"),
          leading: Stack(
            children: [
              CircleAvatar(
                  backgroundImage: const Image(
                image: AssetImage("assets/user.png"),
              ).image),
              const Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Colors.green,
                ),
              )
            ],
          ),
          title: const Text("Other User"),
          subtitle: const Text("Hello"),
          trailing: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryColor,
                  radius: 12,
                  child: Text(
                    "10",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text("20:50")
              ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/search");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

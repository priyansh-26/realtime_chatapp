// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/controllers/local_saved_data.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                    backgroundImage: value.getUserProfile != null ||
                            value.getUserProfile != ""
                        ? CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${value.getUserProfile}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin")
                        : Image(
                            image: AssetImage("assets/user.png"),
                          ).image),
                title: Text(value.getUserName),
                subtitle: Text(value.getUserNumber),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => Navigator.pushNamed(context, "/update",
                    arguments: {"title": "edit"}),
              ),
              Divider(),
              ListTile(
                onTap: () async {
                  await LocalSavedData.clearAllData();
                  await logoutUser();
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (route) => false);
                },
                leading: Icon(Icons.logout_outlined),
                title: Text("Logout"),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("About"),
              ),
            ],
          ),
        );
      },
    );
  }
}

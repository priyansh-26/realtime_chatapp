import 'package:flutter/material.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
                backgroundImage: const Image(
              image: AssetImage("assets/user.png"),
            ).image),
            title: const Text("Current User"),
            subtitle: const Text("+91-8755076120"),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => Navigator.pushNamed(context, "/update"),
          ),
          Divider(),
          ListTile(
            onTap: () {
              logoutUser();
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
  }
}

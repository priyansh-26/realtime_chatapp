import 'package:flutter/material.dart';
import 'package:realtime_chatapp/constants/colors.dart';

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
            child: CircleAvatar(
                backgroundImage: const Image(
              image: AssetImage("assets/user.png"),
            ).image),
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

import 'package:flutter/material.dart';
import 'package:realtime_chatapp/constants/colors.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                ),
                Stack(
                  children: [
                    CircleAvatar(
                        radius: 120,
                        backgroundImage: const Image(
                          image: AssetImage("assets/user.png"),
                        ).image),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Enter your name"),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Phone Number"),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Update"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}

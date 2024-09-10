import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    // try to load the data from local database
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
      // Provider.of<UserDataProvider>(context, listen: false)
      //     .loadUserData(userId!);
      // imageId =
      //     Provider.of<UserDataProvider>(context, listen: false).getUserProfile;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> datapassed =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Consumer<UserDataProvider>(
      builder: (context, value, child) {
        _nameController.text = value.getUserName;
        _phoneController.text = value.getUserNumber;
        // imageId = value.getUserProfile;
        // print("set image id to this $imageId");
        return Scaffold(
          appBar: AppBar(
              title: Text(
                  datapassed["title"] == "edit" ? "Update" : "Add Details")),
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
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your name"),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: kSecondaryColor,
                          borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.all(6),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: TextFormField(
                        controller: _phoneController,
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
      },
    );
  }
}

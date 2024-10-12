// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:appwrite/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);

  // handle the search
  void _handleSearch() {
    searchUsers(
            searchItem: _searchController.text,
            userId:
                Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      if (value != null) {
        setState(() {
          searchedUsers = value;
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: 0, documents: []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search Users",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.circular(6)),
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                // ignore: prefer_const_literals_to_create_immutables
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _handleSearch(),
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Enter the name"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _handleSearch();
                    },
                  ),
                ]),
              ),
              ListTile(
                leading: Icon(Icons.group_add_outlined),
                title: Text("Create new group"),
                trailing: Icon(
                  Icons
                      .arrow_forward_ios, // Add an arrow for navigation indication
                  color: Colors.grey, // Subtle arrow color
                  size: 18,
                ),
              )
            ],
          ),
        ),
      ),
      body: searchedUsers.total == -1
          ? Center(
              child: Text("Use the search box to search users"),
            )
          : searchedUsers.total == 0
              ? Center(
                  child: Text("No users found"),
                )
              : ListView.builder(
                  itemCount: searchedUsers.documents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, "/chat",
                            arguments: UserData.toMap(
                                searchedUsers.documents[index].data));
                      },
                      leading: CircleAvatar(
                        backgroundImage: searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    null &&
                                searchedUsers
                                        .documents[index].data["profile_pic"] !=
                                    ""
                            ? CachedNetworkImageProvider(
                                "https://cloud.appwrite.io/v1/storage/buckets/66e5c8d500029fa844fb/files/${searchedUsers.documents[index].data["profile_pic"]}/view?project=66df2f70000a3570467e&project=66df2f70000a3570467e&mode=admin")
                            : Image(image: AssetImage("assets/user.png")).image,
                      ),
                      title: Text(searchedUsers.documents[index].data["name"] ??
                          "No name"),
                      subtitle: Text(
                          searchedUsers.documents[index].data["phone_no"] ??
                              ""),
                    );
                  },
                ),
    );
  }
}

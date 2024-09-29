// ignore_for_file: avoid_print

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/models/chat_data_model.dart';
import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';
import 'package:realtime_chatapp/main.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

Client client = Client()
    .setEndpoint('https://cloud.appwrite.io/v1')
    .setProject('66df2f70000a3570467e')
    .setSelfSigned(
        status: true); // For self signed certificates, only use for development

const String db = "66df308a001d782b7db4";
const String userCollection = "66df30a2001147188e51";
const String chatCollection = "66f1a4e50031c2a2ea5e";
const String storageBucket = "66e5c8d500029fa844fb";

Account account = Account(client);
final Databases databases = Databases(client);
final Storage storage = Storage(client);

//save phone number to database(new user)
Future<bool> savePhoneToDb(
    {required String phoneno, required String userId}) async {
  try {
    final response = await databases.createDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {
          'phone_no': phoneno,
          "userId": userId,
        });

    print(response);
    return true;
  } on AppwriteException catch (e) {
    print("Cannot save to user database :$e");
    return false;
  }
}

//check number exist or not in DB
Future<String> checkPhoneNumber({required String phoneno}) async {
  try {
    final DocumentList matchUser = await databases.listDocuments(
        databaseId: db,
        collectionId: userCollection,
        queries: [Query.equal("phone_no", phoneno)]);
    if (matchUser.total > 0) {
      final Document user = matchUser.documents[0];

      if (user.data["phone_no"] != null || user.data["phone_no"] != "") {
        return user.data["userId"];
      } else {
        print("no user exist on db");
        return "user_not_exist";
      }
    } else {
      print("no user exist on db");
      return "user_not_exist";
    }
  } on AppwriteException catch (e) {
    print("error on reading database $e");
    return "user_not_exist";
  }
}

// create a phone session , send otp to the phone number
Future<String> createPhoneSession({required String phone}) async {
  try {
    final userId = await checkPhoneNumber(phoneno: phone);
    if (userId == "user_not_exist") {
      // creating a new account
      final Token data =
          await account.createPhoneToken(userId: ID.unique(), phone: phone);

      // save the new user to user collection
      savePhoneToDb(phoneno: phone, userId: data.userId);
      return data.userId;
    }

    // if user is an existing user
    else {
      // create phone token for existing user
      final Token data =
          await account.createPhoneToken(userId: userId, phone: phone);
      return data.userId;
    }
  } catch (e) {
    print("error on create phone session :$e");
    return "login_error";
  }
}

// login with otp
Future<bool> loginWithOtp({required String otp, required String userId}) async {
  try {
    final Session session =
        await account.updatePhoneSession(userId: userId, secret: otp);
    print(session.userId);
    return true;
  } catch (e) {
    print("error on login with otp :$e");
    return false;
  }
}

// to check whether the session exist or not
Future<bool> checkSessions() async {
  try {
    final Session session = await account.getSession(sessionId: "current");
    print("session exist ${session.$id}");
    return true;
  } catch (e) {
    print("session does not exist please login");
    return false;
  }
}

// to logout the user and delete session
Future logoutUser() async {
  await account.deleteSession(sessionId: "current");
}

// load user data
Future<UserData?> getUserDetails({required String userId}) async {
  try {
    final response = await databases.getDocument(
        databaseId: db, collectionId: userCollection, documentId: userId);
    print("getting user data ");
    print(response.data);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(response.data["name"] ?? "");
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(response.data["profile_pic"] ?? "");
    return UserData.toMap(response.data);
  } catch (e) {
    print("error in getting user data :$e");
    return null;
  }
}

// to update the user Data
Future<bool> updateUserDetails(
  String pic, {
  required String userId,
  required String name,
}) async {
  try {
    final data = await databases.updateDocument(
        databaseId: db,
        collectionId: userCollection,
        documentId: userId,
        data: {"name": name, "profile_pic": pic});

    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setUserName(name);
    Provider.of<UserDataProvider>(navigatorKey.currentContext!, listen: false)
        .setProfilePic(pic);
    print(data);
    return true;
  } on AppwriteException catch (e) {
    print("cannot save to db :$e");
    return false;
  }
}

// upload and save image to storage bucket (create new image)
Future<String?> saveImageToBucket({required InputFile image}) async {
  try {
    final response = await storage.createFile(
        bucketId: storageBucket, fileId: ID.unique(), file: image);
    print("the response after save to bucket $response");
    return response.$id;
  } catch (e) {
    print("error on saving image to bucket :$e");
    return null;
  }
}

// update an image in bucket : first delete then create new
Future<String?> updateImageOnBucket(
    {required String oldImageId, required InputFile image}) async {
  try {
    // to delete the old image
    deleteImagefromBucket(oldImageId: oldImageId);

    // create a new image
    final newImage = saveImageToBucket(image: image);

    return newImage;
  } catch (e) {
    print("cannot update / delete image :$e");
    return null;
  }
}

// to only delete the image from the storage bucket
Future<bool> deleteImagefromBucket({required String oldImageId}) async {
  try {
    // to delete the old image
    await storage.deleteFile(bucketId: storageBucket, fileId: oldImageId);
    return true;
  } catch (e) {
    print("cannot update / delete image :$e");
    return false;
  }
}

// to search all the users from the database
Future<DocumentList?> searchUsers(
    {required String searchItem, required String userId}) async {
  try {
    final DocumentList users = await databases
        .listDocuments(databaseId: db, collectionId: userCollection, queries: [
      // Query.search("phone_no", searchItem),
      Query.search("name", searchItem),
      Query.notEqual("userId", userId)
    ]);

    print("total match users ${users.total}");
    return users;
  } catch (e) {
    print("error on search users :$e");
    return null;
  }
}

// create a new chat and save to database
Future createNewChat(
    {required String message,
    required String senderId,
    required String receiverId,
    required bool isImage}) async {
  try {
    final msg = await databases.createDocument(
        databaseId: db,
        collectionId: chatCollection,
        documentId: ID.unique(),
        data: {
          "message": message,
          "senderId": senderId,
          "receiverId": receiverId,
          "timestamp": DateTime.now().toIso8601String(),
          "isSeenbyReceiver": false,
          "isImage": isImage,
          "userData": [senderId, receiverId]
        });

    print("message send");
    return true;
  } catch (e) {
    print("failed to send message :$e");
    return false;
  }
}

// to list all the chats belonging to the current user
Future<Map<String, List<ChatDataModel>>?> currentUserChats(
    String userId) async {
  try {
    var results = await databases
        .listDocuments(databaseId: db, collectionId: chatCollection, queries: [
      Query.or(
          [Query.equal("senderId", userId), Query.equal("receiverId", userId)]),
      Query.orderDesc("timestamp"),
      Query.limit(2000)
    ]);

    final DocumentList chatDocuments = results;

    print(
        "chat documents ${chatDocuments.total} and documents ${chatDocuments.documents.length}");
    Map<String, List<ChatDataModel>> chats = {};

    if (chatDocuments.documents.isNotEmpty) {
      for (var i = 0; i < chatDocuments.documents.length; i++) {
        var doc = chatDocuments.documents[i];
        String sender = doc.data["senderId"];
        String receiver = doc.data["receiverId"];

        MessageModel message = MessageModel.fromMap(doc.data);

        List<UserData> users = [];
        for (var user in doc.data["userData"]) {
          users.add(UserData.toMap(user));
        }

        String key = (sender == userId) ? receiver : sender;

        if (chats[key] == null) {
          chats[key] = [];
        }
        chats[key]!.add(ChatDataModel(message: message, users: users));
      }
    }

    return chats;
  } catch (e) {
    print("error in reading current user chats :$e");
    return null;
  }
}

// to delete the chat from database chat collection
Future deleteCurrentUserChat({required String chatId}) async {
  try {
    await databases.deleteDocument(
        databaseId: db, collectionId: chatCollection, documentId: chatId);
  } catch (e) {
    print("error on deleting chat message : $e");
  }
}

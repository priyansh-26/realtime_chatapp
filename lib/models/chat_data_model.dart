import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/models/user_data.dart';

class ChatDataModel {
  final MessageModel message;
  final List<UserData> users;

  ChatDataModel({required this.message, required this.users});
}

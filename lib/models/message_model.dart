class MessageModel {
  final String message;
  final String sender;
  final String receiver;
  final String? messageId;
  final DateTime timestamp;
  final bool isSeenByReceiver;
  final bool? isImage;

  MessageModel({
    required this.message,
    required this.sender,
    required this.receiver,
    this.messageId,
    required this.timestamp,
    required this.isSeenByReceiver,
    this.isImage,
  });
}

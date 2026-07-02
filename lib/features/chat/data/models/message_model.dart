import 'package:pocketbase/pocketbase.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.createdAt,
  });

  factory MessageModel.fromRecord(RecordModel record) {
    return MessageModel(
      id: record.id,
      senderId: record.getStringValue('sender'),
      receiverId: record.getStringValue('receiver'),
      text: record.getStringValue('text'),
      createdAt: DateTime.parse(record.created),
    );
  }
}

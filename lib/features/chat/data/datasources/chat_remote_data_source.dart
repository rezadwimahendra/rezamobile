import 'package:pocketbase/pocketbase.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<MessageModel>> getMessages(String otherUserId);
  Future<MessageModel> sendMessage(String receiverId, String text);
  Future<List<String>> getChatPartners();
  Future<void> deleteMessage(String messageId);
  void subscribeToMessages(Function(RecordSubscriptionEvent) onEvent);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final PocketBase pb;

  ChatRemoteDataSourceImpl(this.pb);

  @override
  Future<List<MessageModel>> getMessages(String otherUserId) async {
    final currentUserId = pb.authStore.model?.id;
    if (currentUserId == null) return [];

    final result = await pb.collection('messages').getList(
      sort: '-created',
      filter: '(sender = "$currentUserId" && receiver = "$otherUserId") || (sender = "$otherUserId" && receiver = "$currentUserId")',
    );

    return result.items.map((record) => MessageModel(
      id: record.id,
      senderId: record.getStringValue('sender'),
      receiverId: record.getStringValue('receiver'),
      text: record.getStringValue('text'),
      createdAt: DateTime.parse(record.created).toLocal(),
    )).toList();
  }

  @override
  Future<MessageModel> sendMessage(String receiverId, String text) async {
    final currentUserId = pb.authStore.model?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    final record = await pb.collection('messages').create(body: {
      'sender': currentUserId,
      'receiver': receiverId,
      'text': text,
    });

    return MessageModel(
      id: record.id,
      senderId: record.getStringValue('sender'),
      receiverId: record.getStringValue('receiver'),
      text: record.getStringValue('text'),
      createdAt: DateTime.parse(record.created).toLocal(),
    );
  }

  @override
  Future<List<String>> getChatPartners() async {
    final currentUserId = pb.authStore.model?.id;
    if (currentUserId == null) return [];

    final result = await pb.collection('messages').getList(
      sort: '-created',
      filter: 'sender = "$currentUserId" || receiver = "$currentUserId"',
      perPage: 200,
    );

    final partnerIds = <String>{};
    for (var record in result.items) {
      final sender = record.getStringValue('sender');
      final receiver = record.getStringValue('receiver');
      if (sender != currentUserId) partnerIds.add(sender);
      if (receiver != currentUserId) partnerIds.add(receiver);
    }
    return partnerIds.toList();
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await pb.collection('messages').delete(messageId);
  }

  @override
  void subscribeToMessages(Function(RecordSubscriptionEvent) onEvent) {
    pb.collection('messages').subscribe('*', (e) {
      onEvent(e);
    });
  }
}

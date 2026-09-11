import '../../common/models/paginated.dart';
import '../../common/models/user.dart';
import '../../core/utils/media.dart';
import '../masters/master_model.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderType = 'USER',
    this.content,
    this.fileUrl,
    this.fileType = 'TEXT',
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final int chatId;
  final int senderId;
  final String senderType;
  final String? content;
  final String? fileUrl;
  final String fileType;
  final bool isRead;
  final String? createdAt;

  bool get isMedia => fileType != 'TEXT' && (fileUrl?.isNotEmpty ?? false);
  String get mediaUrl => chatMediaUrl(fileUrl);

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: asInt(j['id']) ?? 0,
        chatId: asInt(j['chatId']) ?? 0,
        senderId: asInt(j['senderId']) ?? 0,
        senderType: asString(j['senderType'], 'USER'),
        content: j['content']?.toString(),
        fileUrl: j['fileUrl']?.toString(),
        fileType: asString(j['fileType'], 'TEXT'),
        isRead: asBool(j['isRead']),
        createdAt: j['createdAt']?.toString(),
      );
}

class Chat {
  const Chat({
    required this.id,
    required this.userId,
    required this.masterId,
    this.master,
    this.user,
    this.lastMessage,
    this.createdAt,
  });

  final int id;
  final int userId;
  final int masterId;
  final Master? master;
  final AppUser? user;
  final ChatMessage? lastMessage;
  final String? createdAt;

  String get title => master?.name ?? user?.fullName ?? 'Suhbat';
  String get avatar => mediaUrl(master?.profileImg ?? master?.user?.profileImg);

  factory Chat.fromJson(Map<String, dynamic> j) {
    final msgs = j['messages'];
    ChatMessage? last;
    if (msgs is List && msgs.isNotEmpty && msgs.last is Map) {
      last = ChatMessage.fromJson(Map<String, dynamic>.from(msgs.last));
    } else if (j['lastMessage'] is Map) {
      last = ChatMessage.fromJson(Map<String, dynamic>.from(j['lastMessage']));
    }
    return Chat(
      id: asInt(j['id']) ?? 0,
      userId: asInt(j['userId']) ?? 0,
      masterId: asInt(j['masterId']) ?? 0,
      master: j['master'] is Map
          ? Master.fromJson(Map<String, dynamic>.from(j['master']))
          : null,
      user: j['user'] is Map
          ? AppUser.fromJson(Map<String, dynamic>.from(j['user']))
          : null,
      lastMessage: last,
      createdAt: j['createdAt']?.toString(),
    );
  }
}

import 'package:mu_study/models/models.dart';

class ChatListEntry {
  const ChatListEntry._({this.date, this.message});

  factory ChatListEntry.date(DateTime date) => ChatListEntry._(date: date);

  factory ChatListEntry.message(ChatMessage message) =>
      ChatListEntry._(message: message);

  final DateTime? date;
  final ChatMessage? message;
}

List<ChatListEntry> chatEntriesFor(List<ChatMessage> messages) {
  final entries = <ChatListEntry>[];
  DateTime? lastDay;
  for (final message in messages) {
    if (message.isDeleted) continue;
    final local = message.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (lastDay == null || day != lastDay) {
      entries.add(ChatListEntry.date(day));
      lastDay = day;
    }
    entries.add(ChatListEntry.message(message));
  }
  return entries;
}

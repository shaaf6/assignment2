import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  final String id;
  final String topicId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;

  const ReplyModel({
    required this.id,
    required this.topicId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
  });

  factory ReplyModel.fromMap(
    Map<String, dynamic> map,
    String id,
    String topicId,
  ) =>
      ReplyModel(
        id: id,
        topicId: topicId,
        content: map['content'] as String? ?? '',
        authorId: map['authorId'] as String? ?? '',
        authorName: map['authorName'] as String? ?? '',
        authorEmail: map['authorEmail'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'topicId': topicId,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReplyModel && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

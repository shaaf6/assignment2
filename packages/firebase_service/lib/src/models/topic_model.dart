import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorEmail;
  final DateTime createdAt;
  final int replyCount;

  const TopicModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorEmail,
    required this.createdAt,
    this.replyCount = 0,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map, String id) => TopicModel(
        id: id,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        authorId: map['authorId'] as String? ?? '',
        authorName: map['authorName'] as String? ?? '',
        authorEmail: map['authorEmail'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        replyCount: map['replyCount'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'authorEmail': authorEmail,
        'createdAt': Timestamp.fromDate(createdAt),
        'replyCount': replyCount,
      };

  TopicModel copyWith({int? replyCount}) => TopicModel(
        id: id,
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        authorEmail: authorEmail,
        createdAt: createdAt,
        replyCount: replyCount ?? this.replyCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TopicModel && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

import 'package:equatable/equatable.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopics extends ForumEvent {
  const LoadTopics();
}

class CreateTopic extends ForumEvent {
  final String title;
  final String content;

  const CreateTopic({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class LoadReplies extends ForumEvent {
  final String topicId;

  const LoadReplies(this.topicId);

  @override
  List<Object?> get props => [topicId];
}

class AddReply extends ForumEvent {
  final String topicId;
  final String content;

  const AddReply({required this.topicId, required this.content});

  @override
  List<Object?> get props => [topicId, content];
}

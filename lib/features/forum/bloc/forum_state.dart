import 'package:equatable/equatable.dart';
import 'package:firebase_service/firebase_service.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumLoading extends ForumState {
  const ForumLoading();
}

// ── Topics states ─────────────────────────────────────────────
class TopicsLoaded extends ForumState {
  final List<TopicModel> topics;
  final bool isCreating;

  const TopicsLoaded(this.topics, {this.isCreating = false});

  @override
  List<Object?> get props => [topics, isCreating];
}

// ── Replies states ────────────────────────────────────────────
class RepliesLoaded extends ForumState {
  final List<ReplyModel> replies;
  final bool isAdding;

  const RepliesLoaded(this.replies, {this.isAdding = false});

  @override
  List<Object?> get props => [replies, isAdding];
}

class ForumError extends ForumState {
  final String message;

  const ForumError(this.message);

  @override
  List<Object?> get props => [message];
}

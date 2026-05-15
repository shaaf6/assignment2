import 'dart:async';

import 'package:firebase_service/firebase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'forum_event.dart';
import 'forum_state.dart';

// ── Internal stream-bridge events (same library as BLoC) ──────
class _TopicsReceived extends ForumEvent {
  final List<TopicModel> topics;
  const _TopicsReceived(this.topics);
  @override
  List<Object?> get props => [topics];
}

class _TopicsErrored extends ForumEvent {
  final String message;
  const _TopicsErrored(this.message);
  @override
  List<Object?> get props => [message];
}

class _RepliesReceived extends ForumEvent {
  final List<ReplyModel> replies;
  const _RepliesReceived(this.replies);
  @override
  List<Object?> get props => [replies];
}

class _RepliesErrored extends ForumEvent {
  final String message;
  const _RepliesErrored(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────
class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  StreamSubscription<List<TopicModel>>? _topicsSub;
  StreamSubscription<List<ReplyModel>>? _repliesSub;

  List<TopicModel> _topics = [];
  List<ReplyModel> _replies = [];

  ForumBloc(this._firestoreService, this._authService)
      : super(const ForumInitial()) {
    on<LoadTopics>(_onLoadTopics);
    on<_TopicsReceived>(_onTopicsReceived);
    on<_TopicsErrored>(_onTopicsErrored);
    on<CreateTopic>(_onCreateTopic);
    on<LoadReplies>(_onLoadReplies);
    on<_RepliesReceived>(_onRepliesReceived);
    on<_RepliesErrored>(_onRepliesErrored);
    on<AddReply>(_onAddReply);
  }

  // ── Topics ─────────────────────────────────────────────────

  Future<void> _onLoadTopics(
    LoadTopics event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    await _topicsSub?.cancel();
    _topicsSub = _firestoreService.getTopics().listen(
          (topics) => add(_TopicsReceived(topics)),
          onError: (_) => add(const _TopicsErrored('Failed to load topics.')),
        );
  }

  void _onTopicsReceived(_TopicsReceived event, Emitter<ForumState> emit) {
    _topics = event.topics;
    emit(TopicsLoaded(_topics));
  }

  void _onTopicsErrored(_TopicsErrored event, Emitter<ForumState> emit) {
    emit(ForumError(event.message));
  }

  Future<void> _onCreateTopic(
    CreateTopic event,
    Emitter<ForumState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(const ForumError('You must be logged in to create a topic.'));
      return;
    }
    emit(TopicsLoaded(_topics, isCreating: true));
    try {
      await _firestoreService.createTopic(TopicModel(
        id: '',
        title: event.title.trim(),
        content: event.content.trim(),
        authorId: user.uid,
        authorName: user.displayName,
        authorEmail: user.email,
        createdAt: DateTime.now(),
      ));
    } catch (_) {
      emit(const ForumError('Failed to create topic. Please try again.'));
    }
  }

  // ── Replies ────────────────────────────────────────────────

  Future<void> _onLoadReplies(
    LoadReplies event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());
    _replies = [];
    await _repliesSub?.cancel();
    _repliesSub = _firestoreService.getReplies(event.topicId).listen(
          (replies) => add(_RepliesReceived(replies)),
          onError: (_) =>
              add(const _RepliesErrored('Failed to load replies.')),
        );
  }

  void _onRepliesReceived(_RepliesReceived event, Emitter<ForumState> emit) {
    _replies = event.replies;
    emit(RepliesLoaded(_replies));
  }

  void _onRepliesErrored(_RepliesErrored event, Emitter<ForumState> emit) {
    emit(ForumError(event.message));
  }

  Future<void> _onAddReply(
    AddReply event,
    Emitter<ForumState> emit,
  ) async {
    final user = _authService.currentUser;
    if (user == null) {
      emit(const ForumError('You must be logged in to reply.'));
      return;
    }
    emit(RepliesLoaded(_replies, isAdding: true));
    try {
      await _firestoreService.addReply(
        topicId: event.topicId,
        reply: ReplyModel(
          id: '',
          topicId: event.topicId,
          content: event.content.trim(),
          authorId: user.uid,
          authorName: user.displayName,
          authorEmail: user.email,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      emit(const ForumError('Failed to add reply. Please try again.'));
    }
  }

  @override
  Future<void> close() async {
    await _topicsSub?.cancel();
    await _repliesSub?.cancel();
    return super.close();
  }
}

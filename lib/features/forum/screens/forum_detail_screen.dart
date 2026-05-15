import 'package:firebase_service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../widgets/reply_card.dart';

class ForumDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const ForumDetailScreen({super.key, required this.topic});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(LoadReplies(widget.topic.id));
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitReply(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<ForumBloc>().add(AddReply(
            topicId: widget.topic.id,
            content: _replyController.text.trim(),
          ));
      _replyController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is ForumError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is RepliesLoaded && !state.isAdding) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.topic.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ── Topic body ──────────────────────────────
                  SliverToBoxAdapter(
                    child: _TopicBody(topic: widget.topic),
                  ),
                  // ── Replies header ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: BlocBuilder<ForumBloc, ForumState>(
                        builder: (context, state) {
                          final count = state is RepliesLoaded
                              ? state.replies.length
                              : 0;
                          return Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline,
                                  size: 18, color: AppTheme.seaGreen),
                              const SizedBox(width: 6),
                              Text(
                                '$count ${count == 1 ? 'Reply' : 'Replies'}',
                                style: const TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  // ── Replies list ────────────────────────────
                  BlocBuilder<ForumBloc, ForumState>(
                    builder: (context, state) {
                      if (state is ForumLoading) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.seaGreen),
                          ),
                        );
                      }

                      if (state is RepliesLoaded) {
                        if (state.replies.isEmpty) {
                          return const SliverFillRemaining(
                            child: _EmptyRepliesView(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => ReplyCard(
                              reply: state.replies[i],
                              index: i,
                            ),
                            childCount: state.replies.length,
                          ),
                        );
                      }

                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
            // ── Reply input bar ─────────────────────────────
            _ReplyInputBar(
              controller: _replyController,
              formKey: _formKey,
              onSubmit: () => _submitReply(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Topic body card ────────────────────────────────────────────
class _TopicBody extends StatelessWidget {
  final TopicModel topic;
  const _TopicBody({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seaGreen.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppTheme.seaGreen.withValues(alpha: 0.2),
                  child: Text(
                    topic.authorName.isNotEmpty
                        ? topic.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.seaGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.authorName,
                      style: const TextStyle(
                        color: AppTheme.primaryGreenLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(topic.createdAt),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 12),
            Text(
              topic.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reply input bar ───────────────────────────────────────────
class _ReplyInputBar extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;

  const _ReplyInputBar({
    required this.controller,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumBloc, ForumState>(
      builder: (context, state) {
        final isAdding = state is RepliesLoaded && state.isAdding;
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      filled: true,
                      fillColor: AppTheme.backgroundGreen,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Reply cannot be empty';
                      }
                      if (v.trim().length < 2) {
                        return 'Reply is too short';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isAdding
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 44,
                          height: 44,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppTheme.seaGreen,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          key: const ValueKey('send'),
                          radius: 22,
                          backgroundColor: AppTheme.seaGreen,
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                            onPressed: onSubmit,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyRepliesView extends StatelessWidget {
  const _EmptyRepliesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 56,
              color: AppTheme.seaGreen.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          const Text('No replies yet',
              style: TextStyle(
                  color: AppTheme.primaryGreenLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Be the first to reply!',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/screens/login_screen.dart';
import '../bloc/forum_bloc.dart';
import '../bloc/forum_event.dart';
import '../bloc/forum_state.dart';
import '../widgets/topic_card.dart';
import 'create_topic_screen.dart';
import 'forum_detail_screen.dart';

class ForumListScreen extends StatefulWidget {
  const ForumListScreen({super.key});

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ForumBloc>().add(const LoadTopics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum_rounded, size: 22),
              SizedBox(width: 8),
              Text('UniForums'),
            ],
          ),
          actions: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name = state is AuthAuthenticated
                    ? state.user.displayName
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTopicScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('New Topic'),
        ),
        body: BlocBuilder<ForumBloc, ForumState>(
          builder: (context, state) {
            if (state is ForumLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.seaGreen),
              );
            }

            if (state is ForumError) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<ForumBloc>().add(const LoadTopics()),
              );
            }

            if (state is TopicsLoaded) {
              return Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: state.topics.isEmpty
                        ? const _EmptyTopicsView()
                        : _TopicsList(topics: state.topics),
                  ),
                  if (state.isCreating)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        color: AppTheme.seaGreen,
                        backgroundColor: AppTheme.backgroundGreen,
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(color: AppTheme.primaryGreen)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.primaryGreenLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _TopicsList extends StatelessWidget {
  final List topics;
  const _TopicsList({required this.topics});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.seaGreen,
      onRefresh: () async =>
          context.read<ForumBloc>().add(const LoadTopics()),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: topics.length,
        itemBuilder: (context, i) => TopicCard(
          topic: topics[i],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ForumDetailScreen(topic: topics[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTopicsView extends StatelessWidget {
  const _EmptyTopicsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80,
              color: AppTheme.seaGreen.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No topics yet',
              style: TextStyle(
                  color: AppTheme.primaryGreenLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Be the first to start a discussion!',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

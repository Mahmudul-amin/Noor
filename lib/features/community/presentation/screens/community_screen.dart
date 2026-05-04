import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class _Post {
  final String id, userName, userInitial, timeAgo, text;
  final Color avatarColor;
  int likes;
  bool liked = false;
  _Post({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.timeAgo,
    required this.text,
    required this.avatarColor,
    this.likes = 0,
  });
}

final _postsProvider = StateNotifierProvider<_PostsNotifier, List<_Post>>(
    (ref) => _PostsNotifier());

class _PostsNotifier extends StateNotifier<List<_Post>> {
  _PostsNotifier()
      : super([
          _Post(
              id: '1',
              userName: 'Ahmad Hassan',
              userInitial: 'A',
              timeAgo: '2m ago',
              avatarColor: AppColors.primary,
              likes: 34,
              text:
                  'Alhamdulillah for another blessed Friday. May Allah accept our prayers and forgive our sins. JazakAllah khayran to everyone in this community! 🤲'),
          _Post(
              id: '2',
              userName: 'Fatimah Al-Zahra',
              userInitial: 'F',
              timeAgo: '15m ago',
              avatarColor: AppColors.fajr,
              likes: 89,
              text:
                  '"And whoever relies upon Allah – then He is sufficient for him." (At-Talaq 65:3)\n\nShare your gratitude today! What are you thankful for? ✨'),
          _Post(
              id: '3',
              userName: 'Omar Khalid',
              userInitial: 'O',
              timeAgo: '1h ago',
              avatarColor: AppColors.gold,
              likes: 22,
              text:
                  'Reminder: The last third of the night is the best time for du\'a and tahajjud. Set your alarm and seek closeness to Allah tonight 🌙'),
          _Post(
              id: '4',
              userName: 'Khadijah Yusuf',
              userInitial: 'K',
              timeAgo: '3h ago',
              avatarColor: AppColors.maghrib,
              likes: 56,
              text:
                  'Just completed reading Surah Al-Kahf! It\'s Friday, the day of Jumu\'ah — don\'t forget to read it for the light between two Fridays. 📖'),
          _Post(
              id: '5',
              userName: 'Ibrahim Siddiq',
              userInitial: 'I',
              timeAgo: '5h ago',
              avatarColor: AppColors.success,
              likes: 143,
              text:
                  'Subhan Allah, I reached a 30-day streak on the habit tracker! Consistency is key. May Allah keep us steadfast on the straight path. 💚'),
        ]);

  void toggleLike(String id) {
    state = state.map((p) {
      if (p.id == id) {
        p.liked = !p.liked;
        p.likes += p.liked ? 1 : -1;
      }
      return p;
    }).toList();
  }

  void addPost(String text) {
    final p = _Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: 'You',
        userInitial: 'Y',
        timeAgo: 'just now',
        text: text,
        avatarColor: AppColors.primary,
        likes: 0);
    state = [p, ...state];
  }
}

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _ctrl = TextEditingController();

  void _showPostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Share with Community',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 16),
          TextField(
              controller: _ctrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'Share a thought, reminder, or du\'a...')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_ctrl.text.trim().isNotEmpty) {
                ref.read(_postsProvider.notifier).addPost(_ctrl.text.trim());
                _ctrl.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Post'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final posts = ref.watch(_postsProvider);
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
            child: Container(
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
          child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Community',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('Connect with the Ummah 🌍',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14)),
                    ]),
              )),
        )),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
            (ctx, i) => _PostCard(
                post: posts[i],
                onLike: () =>
                    ref.read(_postsProvider.notifier).toggleLike(posts[i].id)),
            childCount: posts.length,
          )),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('Post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final _Post post;
  final VoidCallback onLike;
  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? const Color(0xFF1E3045) : const Color(0xFFE8F5EE)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: post.avatarColor.withValues(alpha: 0.2),
              child: Text(post.userInitial,
                  style: TextStyle(
                      color: post.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(post.userName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(post.timeAgo,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textLight)),
              ])),
          const Icon(Icons.more_horiz_rounded, color: AppColors.textLight),
        ]),
        const SizedBox(height: 14),
        Text(post.text, style: const TextStyle(fontSize: 14, height: 1.6)),
        const SizedBox(height: 14),
        Row(children: [
          GestureDetector(
            onTap: onLike,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: post.liked
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: post.liked
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.transparent),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    post.liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: post.liked ? AppColors.primary : AppColors.textLight,
                    size: 18),
                const SizedBox(width: 5),
                Text('${post.likes}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: post.liked
                            ? AppColors.primary
                            : AppColors.textLight)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          Row(children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.textLight, size: 18),
            const SizedBox(width: 5),
            const Text('Reply',
                style: TextStyle(fontSize: 13, color: AppColors.textLight)),
          ]),
          const Spacer(),
          const Icon(Icons.share_outlined,
              color: AppColors.textLight, size: 18),
        ]),
      ]),
    );
  }
}

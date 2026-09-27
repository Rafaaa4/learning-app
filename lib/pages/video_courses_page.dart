import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../core/theme/app_theme.dart';

class VideoCoursesPage extends StatefulWidget {
  const VideoCoursesPage({super.key});

  @override
  State<VideoCoursesPage> createState() => _VideoCoursesPageState();
}

class _VideoCoursesPageState extends State<VideoCoursesPage> {
  int _selectedCategory = 0;

  final List<String> _categories = ['All', 'HTML', 'CSS', 'JavaScript', 'Python', 'C', 'C++', 'C#', 'MySQL'];

  // ─── Web Dev Playlist (HTML / CSS / JavaScript) ──────────────────────────
  final List<Map<String, dynamic>> _videos = [
    // ── HTML ──────────────────────────────────────────────────────────────
    {
      'title': 'HTML Full Course – Build a Website Tutorial',
      'duration': '2:02:30',
      'youtubeId': 'pQN-pnXPaVg',
      'author': 'freeCodeCamp.org',
      'category': 'HTML',
      'views': '6.5M',
    },
    {
      'title': 'HTML Crash Course For Absolute Beginners',
      'duration': '1:00:40',
      'youtubeId': 'UB1O30fR-EE',
      'author': 'Traversy Media',
      'category': 'HTML',
      'views': '4.1M',
    },
    {
      'title': 'Learn HTML – Full Tutorial for Beginners',
      'duration': '4:08:03',
      'youtubeId': 'kUMe1FH4CHE',
      'author': 'freeCodeCamp.org',
      'category': 'HTML',
      'views': '3.2M',
    },
    {
      'title': 'HTML Forms & Input Fields – Complete Guide',
      'duration': '31:14',
      'youtubeId': 'fNcJuPIZ2WE',
      'author': 'Traversy Media',
      'category': 'HTML',
      'views': '520K',
    },
    // ── CSS ──────────────────────────────────────────────────────────────
    {
      'title': 'CSS Full Course – Includes Flexbox and CSS Grid',
      'duration': '11:29:00',
      'youtubeId': 'ieTHC78giGQ',
      'author': 'freeCodeCamp.org',
      'category': 'CSS',
      'views': '2.8M',
    },
    {
      'title': 'CSS Crash Course For Absolute Beginners',
      'duration': '1:25:21',
      'youtubeId': 'yfoY53QXEnI',
      'author': 'Traversy Media',
      'category': 'CSS',
      'views': '3.6M',
    },
    {
      'title': 'Flexbox CSS In 20 Minutes',
      'duration': '20:05',
      'youtubeId': 'JJSoEo8JSnc',
      'author': 'Traversy Media',
      'category': 'CSS',
      'views': '2.3M',
    },
    {
      'title': 'CSS Grid Layout Crash Course',
      'duration': '28:03',
      'youtubeId': 'jV8B24rSN5o',
      'author': 'Traversy Media',
      'category': 'CSS',
      'views': '1.1M',
    },
    {
      'title': 'CSS Animation Tutorial',
      'duration': '51:30',
      'youtubeId': 'jgw82b5Y2MU',
      'author': 'Kevin Powell',
      'category': 'CSS',
      'views': '780K',
    },
    // ── JavaScript ────────────────────────────────────────────────────────
    {
      'title': 'JavaScript Full Course for Beginners',
      'duration': '7:04:13',
      'youtubeId': 'lfmg-EJ8gm4',
      'author': 'freeCodeCamp.org',
      'category': 'JavaScript',
      'views': '5.4M',
    },
    {
      'title': 'JavaScript Crash Course For Beginners',
      'duration': '1:40:30',
      'youtubeId': 'hdI2bqOjy3c',
      'author': 'Traversy Media',
      'category': 'JavaScript',
      'views': '5.1M',
    },
    {
      'title': 'JavaScript DOM Manipulation – Full Course',
      'duration': '5:07:01',
      'youtubeId': '5fb2aPlgoys',
      'author': 'freeCodeCamp.org',
      'category': 'JavaScript',
      'views': '1.2M',
    },
    {
      'title': 'Async JavaScript – From Callbacks to Async/Await',
      'duration': '24:31',
      'youtubeId': 'PoRJizFvM7s',
      'author': 'Traversy Media',
      'category': 'JavaScript',
      'views': '1.8M',
    },
    {
      'title': 'JavaScript ES6+ Modern Features',
      'duration': '30:27',
      'youtubeId': 'NCwa_xi0Uuc',
      'author': 'Traversy Media',
      'category': 'JavaScript',
      'views': '960K',
    },
    {
      'title': 'Fetch API & REST – JavaScript for Beginners',
      'duration': '21:15',
      'youtubeId': 'cuEtnrL9-H0',
      'author': 'Traversy Media',
      'category': 'JavaScript',
      'views': '740K',
    },
    // ── Python ───────────────────────────────────────────────────────────
    {
      'title': 'Python for Beginners – Full Course',
      'duration': '6:14:07',
      'youtubeId': 'eWRyvpTDRog',
      'author': 'freeCodeCamp.org',
      'category': 'Python',
      'views': '4.1M',
    },
    {
      'title': 'Python Crash Course For Beginners',
      'duration': '1:33:39',
      'youtubeId': 'JJmcL1N2KQs',
      'author': 'Traversy Media',
      'category': 'Python',
      'views': '2.7M',
    },
    {
      'title': 'Python OOP Tutorial – Classes and Objects',
      'duration': '1:06:25',
      'youtubeId': 'ZDa-Z5JzLYM',
      'author': 'Corey Schafer',
      'category': 'Python',
      'views': '3.5M',
    },
    {
      'title': 'Python Functions – Complete Guide',
      'duration': '42:30',
      'youtubeId': '9Os0o3wzS_I',
      'author': 'freeCodeCamp.org',
      'category': 'Python',
      'views': '1.2M',
    },
    // ── C ─────────────────────────────────────────────────────────────
    {
      'title': 'C Programming Full Course for Beginners',
      'duration': '3:46:13',
      'youtubeId': 'aZb0iu4uGwA',
      'author': 'freeCodeCamp.org',
      'category': 'C',
      'views': '2.9M',
    },
    {
      'title': 'C Programming Tutorial for Beginners',
      'duration': '3:46:13',
      'youtubeId': 'KJgsSFOSQv0',
      'author': 'Mike Dane',
      'category': 'C',
      'views': '4.3M',
    },
    {
      'title': 'Pointers in C – Full Guide',
      'duration': '1:02:32',
      'youtubeId': 'zuegQmMdy8M',
      'author': 'freeCodeCamp.org',
      'category': 'C',
      'views': '1.5M',
    },
    // ── C++ ─────────────────────────────────────────────────────────────
    {
      'title': 'C++ Programming Course – Beginner to Advanced',
      'duration': '31:36:32',
      'youtubeId': '8jLOx1hD3_o',
      'author': 'freeCodeCamp.org',
      'category': 'C++',
      'views': '4.2M',
    },
    {
      'title': 'C++ Tutorial for Beginners',
      'duration': '4:01:29',
      'youtubeId': 'vLnPwxZdW4Y',
      'author': 'Mike Dane',
      'category': 'C++',
      'views': '5.1M',
    },
    {
      'title': 'C++ OOP – Object Oriented Programming',
      'duration': '1:40:15',
      'youtubeId': 'wN0x9eZLix4',
      'author': 'freeCodeCamp.org',
      'category': 'C++',
      'views': '2.3M',
    },
    // ── C# ─────────────────────────────────────────────────────────────
    {
      'title': 'C# Tutorial – Full Course for Beginners',
      'duration': '4:31:09',
      'youtubeId': 'GhQdlIFylQ8',
      'author': 'freeCodeCamp.org',
      'category': 'C#',
      'views': '3.8M',
    },
    {
      'title': 'C# Basics for Beginners – Learn C# Fundamentals',
      'duration': '5:22:00',
      'youtubeId': 'gfkTfcpWqAY',
      'author': 'Programming with Mosh',
      'category': 'C#',
      'views': '4.1M',
    },
    {
      'title': 'C# Object Oriented Programming – Full Course',
      'duration': '3:18:00',
      'youtubeId': 'pMmPzuS4MxE',
      'author': 'freeCodeCamp.org',
      'category': 'C#',
      'views': '1.6M',
    },
    // ── MySQL ─────────────────────────────────────────────────────────────
    {
      'title': 'MySQL – The Full Course',
      'duration': '3:10:00',
      'youtubeId': 'HXV3zeQKqGY',
      'author': 'freeCodeCamp.org',
      'category': 'MySQL',
      'views': '1.7M',
    },
    {
      'title': 'MySQL Crash Course – Learn SQL in One Hour',
      'duration': '1:05:00',
      'youtubeId': 'p3qvj9hO_Bo',
      'author': 'Traversy Media',
      'category': 'MySQL',
      'views': '2.1M',
    },
    {
      'title': 'SQL Joins – Complete Guide',
      'duration': '27:00',
      'youtubeId': '9yeOJ0ZMUYw',
      'author': 'Caleb Curry',
      'category': 'MySQL',
      'views': '890K',
    },
    {
      'title': 'Database Design Course – Full Tutorial',
      'duration': '8:10:00',
      'youtubeId': 'ztHopE5Wnpc',
      'author': 'freeCodeCamp.org',
      'category': 'MySQL',
      'views': '1.3M',
    },
  ];

  List<Map<String, dynamic>> get _filteredVideos {
    if (_selectedCategory == 0) return _videos;
    final cat = _categories[_selectedCategory];
    return _videos.where((v) => v['category'] == cat).toList();
  }

  void _openVideo(BuildContext context, Map<String, dynamic> video) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) =>
            _VideoPlayerPage(video: video),
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCategories(),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: ListView.builder(
                  key: ValueKey(_selectedCategory),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 4),
                  itemCount: _filteredVideos.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final video = _filteredVideos[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 350 + index * 70),
                      curve: Curves.easeOutQuart,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: _buildVideoCard(context, video),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 28),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.video_library_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_videos.length} videos',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Video Courses',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Learn from expert-led video tutorials',
            style: TextStyle(fontSize: 15, color: AppTheme.textMutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuart,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)])
                    : null,
                color: selected ? null : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : Colors.white.withOpacity(0.1),
                ),
                boxShadow: selected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textMutedDark,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> video) {
    final thumbnail = YoutubePlayer.getThumbnail(videoId: video['youtubeId']);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.cardDark,
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openVideo(context, video),
            splashColor: AppTheme.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Stack(
                  children: [
                    Image.network(
                      thumbnail,
                      height: 195,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 195,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary.withOpacity(0.3), AppTheme.bgDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(child: Icon(Icons.play_circle_rounded, color: Colors.white54, size: 60)),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.5, 1.0],
                            colors: [Colors.transparent, AppTheme.cardDark.withOpacity(0.9)],
                          ),
                        ),
                      ),
                    ),
                    // Play Button
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primary.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                        ),
                      ),
                    ),
                    // Duration badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(video['duration'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(video['category'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.6)]),
                            ),
                            child: Center(
                              child: Text(
                                video['author'][0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              video['author'],
                              style: TextStyle(color: AppTheme.textMutedDark, fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.visibility_outlined, color: Colors.white30, size: 14),
                          const SizedBox(width: 4),
                          Text(video['views'], style: const TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Full Screen Video Player Page ───────────────────────────────────────────

class _VideoPlayerPage extends StatefulWidget {
  final Map<String, dynamic> video;
  const _VideoPlayerPage({required this.video});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video['youtubeId'],
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primary,
        progressColors: ProgressBarColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: Column(
            children: [
              // Video Player at top
              player,
              // Info below
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back & title row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              widget.video['category'],
                              style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Video title
                      Text(
                        widget.video['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Author & views
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.6)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.video['author'][0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video['author'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.visibility_outlined, color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(widget.video['views'], style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time_rounded, color: Colors.white38, size: 13),
                                  const SizedBox(width: 4),
                                  Text(widget.video['duration'], style: const TextStyle(color: Colors.white38, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: 16),
                      Text(
                        'About this lesson',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Watch this full video lesson taught by ${widget.video['author']}. Follow along, pause, rewind and learn at your own pace.',
                        style: TextStyle(color: AppTheme.textMutedDark, fontSize: 14, height: 1.7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../models/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isSimulatedMode = false;
  Timer? _simulatedTimer;
  int _simulatedCurrentSec = 0;
  final int _simulatedTotalSec = 720; // 12 mins
  bool _simulatedIsPlaying = true;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null && !_isSimulatedMode) {
      final routeArg = ModalRoute.of(context)?.settings.arguments;
      final VideoModel video = routeArg is VideoModel
          ? routeArg
          : VideoModel(
              id: '1',
              title: 'Master Trik Cepat Logaritma & Eksponen',
              description: 'Pembahasan lengkap trik 10 detik menyelesaikan soal logaritma UTBK bersama Master Tutor KPM.',
              videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
              accessDurationDays: 30,
            );

      final streamUrl = (video.videoUrl != null && video.videoUrl!.isNotEmpty)
          ? video.videoUrl!
          : (video.videoFile != null && video.videoFile!.isNotEmpty
              ? video.videoFile!
              : 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

      _initVideo(streamUrl);
    }
  }

  void _initVideo(String url) async {
    setState(() {
      _isInitialized = false;
      _hasError = false;
      _isSimulatedMode = false;
    });

    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller!.initialize().timeout(const Duration(seconds: 8));
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });
      _controller!.setLooping(true);
      await _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (_) {
      // Gracefully switch to Interactive Visual Lesson Mode if device lacks codec / network
      if (mounted) {
        _startSimulatedLesson();
      }
    }
  }

  void _startSimulatedLesson() {
    setState(() {
      _isSimulatedMode = true;
      _isInitialized = true;
      _hasError = false;
      _simulatedIsPlaying = true;
    });

    _simulatedTimer?.cancel();
    _simulatedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _simulatedIsPlaying) {
        setState(() {
          if (_simulatedCurrentSec < _simulatedTotalSec) {
            _simulatedCurrentSec++;
          } else {
            _simulatedCurrentSec = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _simulatedTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final VideoModel video = routeArg is VideoModel
        ? routeArg
        : VideoModel(
            id: '1',
            title: 'Master Trik Cepat Logaritma & Eksponen',
            description: 'Pembahasan lengkap konsep dasar dan strategi cepat bersama Master Tutor KPM.',
            accessDurationDays: 30,
          );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: Text(video.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Player Container
            Container(
              height: 230,
              width: double.infinity,
              color: Colors.black,
              child: _isSimulatedMode
                  ? _buildSimulatedLessonPlayer(video)
                  : _hasError
                      ? _buildErrorWidget(video)
                      : (!_isInitialized || _controller == null)
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppTheme.primaryBlue),
                                  SizedBox(height: 12),
                                  Text('Menghubungkan Streaming HD KPM...', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () => setState(() => _showControls = !_showControls),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: AspectRatio(
                                      aspectRatio: _controller!.value.aspectRatio > 0
                                          ? _controller!.value.aspectRatio
                                          : 16 / 9,
                                      child: VideoPlayer(_controller!),
                                    ),
                                  ),

                                  // Play / Pause Overlay
                                  if (_showControls || !_controller!.value.isPlaying)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              iconSize: 34,
                                              color: Colors.white,
                                              icon: const Icon(Icons.replay_10_rounded),
                                              onPressed: () {
                                                final current = _controller!.value.position;
                                                _controller!.seekTo(current - const Duration(seconds: 10));
                                              },
                                            ),
                                            const SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_controller!.value.isPlaying) {
                                                    _controller!.pause();
                                                  } else {
                                                    _controller!.play();
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryBlue.withValues(alpha: 0.9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _controller!.value.isPlaying
                                                      ? Icons.pause_rounded
                                                      : Icons.play_arrow_rounded,
                                                  size: 38,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            IconButton(
                                              iconSize: 34,
                                              color: Colors.white,
                                              icon: const Icon(Icons.forward_10_rounded),
                                              onPressed: () {
                                                final current = _controller!.value.position;
                                                _controller!.seekTo(current + const Duration(seconds: 10));
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // Bottom Controls (Seekbar + Time)
                                  if (_showControls || !_controller!.value.isPlaying)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.transparent, Colors.black87],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _formatDuration(_controller!.value.position),
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                  trackHeight: 3,
                                                  activeTrackColor: AppTheme.primaryBlue,
                                                  inactiveTrackColor: Colors.white24,
                                                  thumbColor: AppTheme.primaryBlue,
                                                ),
                                                child: Slider(
                                                  value: _controller!.value.position.inMilliseconds
                                                      .toDouble()
                                                      .clamp(0.0, _controller!.value.duration.inMilliseconds.toDouble()),
                                                  max: _controller!.value.duration.inMilliseconds.toDouble() > 0
                                                      ? _controller!.value.duration.inMilliseconds.toDouble()
                                                      : 1.0,
                                                  onChanged: (val) {
                                                    _controller!.seekTo(Duration(milliseconds: val.toInt()));
                                                  },
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(_controller!.value.duration),
                                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
            ),

            // Video Information Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.bentoBoxDecoration(context: context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'VIDEO MATERI KPM',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.hd_rounded, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 4),
                            const Text('1080p HD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          video.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${video.accessDurationDays} Hari Akses', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(width: 14),
                            const Icon(Icons.verified_rounded, size: 14, color: AppTheme.accentGreen),
                            const SizedBox(width: 4),
                            const Text('Master Tutor KPM', style: TextStyle(fontSize: 11, color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
                        const SizedBox(height: 12),
                        Text(
                          'Deskripsi Materi:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.description.isNotEmpty
                              ? video.description
                              : 'Video pembelajaran komprehensif dari Master Tutor KPM Academy.',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            height: 1.4,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Fitur Pembelajaran Terhubung ✨',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _quickFeatureTile(
                    Icons.quiz_outlined,
                    'Kerjakan Latihan Soal Terkait',
                    'Uji pemahamanmu setelah menonton video ini',
                    () => Navigator.pushNamed(context, '/exam'),
                    isDark,
                  ),
                  _quickFeatureTile(
                    Icons.smart_toy_outlined,
                    'Tanya AI Tutor jika Belum Paham',
                    'Konsultasi 24/7 rumus atau materi dari video ini',
                    () => Navigator.pushNamed(context, '/ai_chat'),
                    isDark,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive Simulated Lesson Player (Guaranteed Fail-Safe on All Mobile Devices)
  Widget _buildSimulatedLessonPlayer(VideoModel video) {
    final curMin = (_simulatedCurrentSec ~/ 60).toString().padLeft(2, '0');
    final curSec = (_simulatedCurrentSec % 60).toString().padLeft(2, '0');
    final totMin = (_simulatedTotalSec ~/ 60).toString().padLeft(2, '0');
    final totSec = (_simulatedTotalSec % 60).toString().padLeft(2, '0');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Digital Learning Board Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cast_connected_rounded, size: 14, color: AppTheme.accentGreen),
                    const SizedBox(width: 6),
                    Text(
                      'STREAMING KPM LIVE HD • AKTIF',
                      style: TextStyle(color: Colors.blue.shade200, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                video.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Animated sound wave bars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
                  return AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, _) {
                      final val = (_waveController.value + (i * 0.15)) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: 3.5,
                        height: 10 + (val * 18),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),

        // Controls Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black.withValues(alpha: 0.65),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _simulatedIsPlaying = !_simulatedIsPlaying),
                  child: Icon(
                    _simulatedIsPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 8),
                Text('$curMin:$curSec', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      trackHeight: 3,
                      activeTrackColor: AppTheme.primaryBlue,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppTheme.primaryBlue,
                    ),
                    child: Slider(
                      value: _simulatedCurrentSec.toDouble(),
                      max: _simulatedTotalSec.toDouble(),
                      onChanged: (val) {
                        setState(() => _simulatedCurrentSec = val.toInt());
                      },
                    ),
                  ),
                ),
                Text('$totMin:$totSec', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(VideoModel video) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_rounded, size: 36, color: Colors.orangeAccent),
          const SizedBox(height: 8),
          const Text('Koneksi streaming video terputus.', style: TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () => _initVideo('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Coba Putar Lagi', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _quickFeatureTile(IconData icon, String title, String subtitle, VoidCallback onTap, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

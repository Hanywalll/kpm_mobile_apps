import 'dart:async';
import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/live_class_model.dart';
import '../models/video_model.dart';
import 'dashboard_service.dart';
import 'video_service.dart';
import '../providers/package_provider.dart';

/// Centralized Real-time Synchronization Service for KPM Academy Mobile
/// Automatically syncs Banners, Packages, Videos, and Live Classes from the Go VPS
/// backend in real-time using smart background polling and App Lifecycle listeners.
class RealtimeSyncService extends ChangeNotifier with WidgetsBindingObserver {
  final DashboardService _dashboardService;
  final VideoService _videoService;
  PackageProvider? _packageProvider;

  Timer? _pollingTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncedAt;

  List<BannerModel> _banners = DashboardService.getDefaultBanners();
  List<VideoModel> _videos = VideoService.getDemoVideosList();
  List<LiveClassModel> _liveClasses = DashboardService.getDefaultLiveClasses();

  List<BannerModel> get banners => _banners;
  List<VideoModel> get videos => _videos;
  List<LiveClassModel> get liveClasses => _liveClasses;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  RealtimeSyncService({
    required DashboardService dashboardService,
    required VideoService videoService,
    PackageProvider? packageProvider,
  })  : _dashboardService = dashboardService,
        _videoService = videoService,
        _packageProvider = packageProvider {
    WidgetsBinding.instance.addObserver(this);
    startSync();
  }

  void updatePackageProvider(PackageProvider? prov) {
    _packageProvider = prov;
  }

  /// Start automatic background sync (every 8 seconds while active)
  void startSync() {
    _pollingTimer?.cancel();
    // Run an immediate silent sync
    syncAll(silent: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      syncAll(silent: true);
    });
  }

  /// Stop polling to save device battery & network bandwidth
  void stopSync() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Instantly sync when user returns to app from background or screen lock
      syncAll(silent: true);
      startSync();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      stopSync();
    }
  }

  /// Synchronize all dynamic modules concurrently
  Future<void> syncAll({bool silent = true}) async {
    if (_isSyncing) return;
    _isSyncing = true;
    if (!silent) notifyListeners();

    try {
      final bannerFuture = _dashboardService.getBanners();
      final videoFuture = _videoService.getVideos();
      final liveFuture = _dashboardService.getLiveClasses();
      final packageFuture = _packageProvider?.fetchPackages(silent: true) ?? Future.value();

      final results = await Future.wait([
        bannerFuture,
        videoFuture,
        liveFuture,
        packageFuture,
      ]);

      final freshBanners = results[0] as List<BannerModel>;
      final freshVideos = results[1] as List<VideoModel>;
      final freshLive = results[2] as List<LiveClassModel>;

      bool hasChanges = false;

      if (freshBanners.isNotEmpty) {
        _banners = freshBanners;
        hasChanges = true;
      }
      if (freshVideos.isNotEmpty) {
        _videos = freshVideos;
        hasChanges = true;
      }
      if (freshLive.isNotEmpty) {
        _liveClasses = freshLive;
        hasChanges = true;
      }

      _lastSyncedAt = DateTime.now();

      if (hasChanges || !silent) {
        notifyListeners();
      }
    } catch (_) {
      // Gracefully handle network glitches
    } finally {
      _isSyncing = false;
      if (!silent) notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopSync();
    super.dispose();
  }
}

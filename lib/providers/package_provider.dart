import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/package_model.dart';
import '../models/order_model.dart';
import '../services/package_service.dart';

class PackageProvider with ChangeNotifier {
  final PackageService _packageService;

  static const String _enrolledPrefKey = 'kpm_enrolled_packages_cache';

  List<PackageModel> _packages = [];
  List<PackageModel> _enrolledPackages = [];
  List<OrderModel> _userOrders = [];
  List<PackageModel> _cartItems = [];
  PackageModel? _selectedPackage;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedJenjang = 'Semua';
  String _selectedKelas = 'Semua';
  bool _isDisposed = false;

  PackageProvider(this._packageService) {
    _loadEnrolledPackagesFromPrefs();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  List<PackageModel> get packages => _packages;
  List<PackageModel> get enrolledPackages => _enrolledPackages;
  List<OrderModel> get userOrders => _userOrders;
  List<PackageModel> get cartItems => _cartItems;
  PackageModel? get selectedPackage => _selectedPackage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedJenjang => _selectedJenjang;
  String get selectedKelas => _selectedKelas;

  int get cartCount => _cartItems.length;
  double get cartTotalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.effectivePrice);
  double get cartOriginalPrice => _cartItems.fold(0.0, (sum, item) => sum + item.price);
  double get cartTotalDiscount => (cartOriginalPrice - cartTotalPrice).clamp(0.0, double.infinity);

  bool isInCart(String packageId) {
    return _cartItems.any((item) => item.id == packageId);
  }

  bool isEnrolled(String packageId) {
    return _enrolledPackages.any((item) => item.id == packageId);
  }

  Future<void> _loadEnrolledPackagesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_enrolledPrefKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List decoded = jsonDecode(cachedJson);
        _enrolledPackages = decoded.map((e) => PackageModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveEnrolledPackagesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = _enrolledPackages.map((e) => e.toJson()).toList();
      await prefs.setString(_enrolledPrefKey, jsonEncode(listMap));
    } catch (_) {}
  }

  void enrollPackage(PackageModel package) {
    if (!_enrolledPackages.any((p) => p.id == package.id)) {
      _enrolledPackages.insert(0, package);
      _saveEnrolledPackagesToPrefs();
      notifyListeners();
    }
  }

  bool addToCart(PackageModel package) {
    if (isInCart(package.id)) {
      return false; // Already in cart
    }
    _cartItems.add(package);
    notifyListeners();
    return true;
  }

  void removeFromCart(String packageId) {
    _cartItems.removeWhere((item) => item.id == packageId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool toggleCart(PackageModel package) {
    if (isInCart(package.id)) {
      removeFromCart(package.id);
      return false;
    } else {
      addToCart(package);
      return true;
    }
  }

  void setSelectedJenjang(String jenjang) {
    _selectedJenjang = jenjang;
    fetchPackages();
  }

  void setSelectedKelas(String kelas) {
    _selectedKelas = kelas;
    fetchPackages();
  }

  Future<void> fetchPackages({
    String? kelas,
    String? jenjang,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeJenjang = jenjang ?? (_selectedJenjang != 'Semua' ? _selectedJenjang : null);
      final activeKelas = kelas ?? (_selectedKelas != 'Semua' ? _selectedKelas : null);

      _packages = await _packageService.getPackages(
        kelas: activeKelas,
        jenjang: activeJenjang,
        search: search,
      );

      // Also ensure enrolled packages are matched with latest package data if needed
      for (final order in _userOrders) {
        if (order.isPaid && order.package != null) {
          enrollPackage(order.package!);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPackageDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPackage = await _packageService.getPackageDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder(String packageId, {double? totalPrice, bool isCustomAmount = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _packageService.createOrder(
        packageId,
        totalPrice: totalPrice,
        isCustomAmount: isCustomAmount,
      );
      await fetchUserOrders();
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchUserOrders() async {
    try {
      _userOrders = await _packageService.getUserOrders();
      for (final o in _userOrders) {
        if (o.isPaid && o.package != null) {
          enrollPackage(o.package!);
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> simulatePay(String orderId, {PackageModel? fallbackPackage}) async {
    try {
      await _packageService.simulatePayOrder(orderId);
    } catch (_) {}
    await fetchUserOrders();
    
    // Enroll the package
    if (fallbackPackage != null) {
      enrollPackage(fallbackPackage);
    } else {
      final matchedOrder = _userOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => OrderModel(id: orderId, userId: '', orderNumber: '', totalPrice: 0),
      );
      if (matchedOrder.package != null) {
        enrollPackage(matchedOrder.package!);
      } else if (_selectedPackage != null) {
        enrollPackage(_selectedPackage!);
      } else if (_packages.isNotEmpty) {
        enrollPackage(_packages.first);
      }
    }
  }

  Future<bool> checkMidtransStatus(String orderId, String orderNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _packageService.checkMidtransStatus(orderNumber);
      final txStatus = res?['transaction_status'] as String?;
      if (txStatus == 'settlement' || txStatus == 'capture' || txStatus == 'paid') {
        await _packageService.simulatePayOrder(orderId);
        await fetchUserOrders();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

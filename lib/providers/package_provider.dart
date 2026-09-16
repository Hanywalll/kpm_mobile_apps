import 'package:flutter/material.dart';
import '../models/package_model.dart';
import '../services/package_service.dart';

class PackageProvider with ChangeNotifier {
  final PackageService _packageService;

  List<PackageModel> _packages = [];
  PackageModel? _selectedPackage;
  bool _isLoading = false;
  String? _errorMessage;

  PackageProvider(this._packageService);

  List<PackageModel> get packages => _packages;
  PackageModel? get selectedPackage => _selectedPackage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPackages({String? gradeLevel, String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _packages = await _packageService.getPackages(
        gradeLevel: gradeLevel,
        category: category,
      );
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

  Future<bool> activateEnrollKey(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _packageService.activateEnrollKey(code);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ServiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addService({
    required String title,
    required String description,
    required String price,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.addService(
        title: title,
        description: description,
        price: price,
        category: category,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add service.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService({
    required String docId,
    required String title,
    required String description,
    required String price,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateService(
        docId: docId,
        title: title,
        description: description,
        price: price,
        category: category,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update service.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService(String docId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteService(docId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete service.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ServiceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> addService({
    required String title,
    required String description,
    required String price,
    required String category,
    String imageUrl = '',
    String tag = '',
    bool isFeatured = false,
    bool isVisible = true,
    int displayOrder = 0,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.addService(
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        tag: tag,
        isFeatured: isFeatured,
        isVisible: isVisible,
        displayOrder: displayOrder,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add service.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateService({
    required String docId,
    required String title,
    required String description,
    required String price,
    required String category,
    String imageUrl = '',
    String tag = '',
    bool isFeatured = false,
    bool isVisible = true,
    int displayOrder = 0,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.updateService(
        docId: docId,
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        tag: tag,
        isFeatured: isFeatured,
        isVisible: isVisible,
        displayOrder: displayOrder,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update service.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteService(String docId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.deleteService(docId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete service.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateServiceVisibility({
    required String docId,
    required bool isVisible,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.updateServiceVisibility(
        docId: docId,
        isVisible: isVisible,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update service visibility.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateServiceFeatured({
    required String docId,
    required bool isFeatured,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.updateServiceFeatured(
        docId: docId,
        isFeatured: isFeatured,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update featured status.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateServiceDisplayOrder({
    required String docId,
    required int displayOrder,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestoreService.updateServiceDisplayOrder(
        docId: docId,
        displayOrder: displayOrder,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update service order.');
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
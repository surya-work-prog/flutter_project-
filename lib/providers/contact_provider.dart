import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ContactProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Valid inquiry statuses for admin workflow
  static const List<String> validStatuses = [
    'new',
    'contacted',
    'booked',
    'completed',
    'cancelled',
  ];

  Future<bool> updateContactStatus({
    required String docId,
    required String status,
  }) async {
    if (!validStatuses.contains(status)) {
      _errorMessage = 'Invalid status value.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateContactStatus(docId, status);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update inquiry status.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateContactNote({
    required String docId,
    required String note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateContactNote(docId, note);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update admin note.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteContact(String docId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteContact(docId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete inquiry.';
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
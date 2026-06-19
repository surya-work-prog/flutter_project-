import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addContact({
    required String name,
    required String email,
    required String message,
  }) async {
    await _db.collection('contacts').add({
      'name': name,
      'email': email,
      'message': message,
      'createdAt': Timestamp.now(),
    });
  }
}
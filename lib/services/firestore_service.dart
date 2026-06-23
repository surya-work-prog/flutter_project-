import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // =========================
  // CONTACTS COLLECTION
  // =========================
  final CollectionReference contacts =
      FirebaseFirestore.instance.collection('contacts');

  Future<void> addContact({
    required String name,
    required String phone,
    required String email,
    required String message,
    required String eventType,
    required String eventDate,
    required String location,
  }) async {
    await contacts.add({
      'name': name,
      'phone': phone,
      'email': email,
      'message': message,
      'eventType': eventType,
      'eventDate': eventDate,
      'location': location,
      'createdAt': Timestamp.now(),
      'status': 'pending',
      'adminNote': '',
    });
  }

  Stream<QuerySnapshot> getContacts() {
    return contacts.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> deleteContact(String docId) async {
    await contacts.doc(docId).delete();
  }

  Future<void> updateContactStatus(String docId, String newStatus) async {
    await contacts.doc(docId).update({
      'status': newStatus,
    });
  }

  Future<void> updateContactNote(String docId, String note) async {
    await contacts.doc(docId).update({
      'adminNote': note,
    });
  }

  // =========================
  // SERVICES COLLECTION
  // =========================
  final CollectionReference services =
      FirebaseFirestore.instance.collection('services');

  Future<void> addService({
    required String title,
    required String description,
    required String price,
    required String category,
  }) async {
    await services.add({
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getServices() {
    return services.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateService({
    required String docId,
    required String title,
    required String description,
    required String price,
    required String category,
  }) async {
    await services.doc(docId).update({
      'title': title,
      'description': description,
      'price': price,
      'category': category,
    });
  }

  Future<void> deleteService(String docId) async {
    await services.doc(docId).delete();
  }
}
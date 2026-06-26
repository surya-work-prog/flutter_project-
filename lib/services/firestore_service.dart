import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // COLLECTION REFERENCES
  // =========================
  CollectionReference<Map<String, dynamic>> get inquiries =>
      _firestore.collection('contacts');

  CollectionReference<Map<String, dynamic>> get services =>
      _firestore.collection('services');

  // =========================================================
  // INQUIRIES / CONTACTS
  // =========================================================

  /// Main method for homepage bridal inquiry form submission.
  /// Stored inside the existing `contacts` collection to avoid breaking current data.
  Future<void> addInquiry({
    required String customerName,
    required String phone,
    required String email,
    required String message,
    required String eventType,
    required String eventDate,
    required String location,
  }) async {
    final now = Timestamp.now();

    await inquiries.add({
      'customerName': customerName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'message': message.trim(),
      'eventType': eventType.trim(),
      'eventDate': eventDate.trim(),
      'location': location.trim(),

      // inquiry workflow
      'status': 'new', // new / contacted / booked / completed / cancelled
      'adminNote': '',

      // timestamps
      'createdAt': now,
      'updatedAt': now,
    });
  }

  /// Backward-compatible wrapper so old UI code using addContact() won't break.
  Future<void> addContact({
    required String customerName,
    required String phone,
    required String email,
    required String message,
    required String eventType,
    required String eventDate,
    required String location,
    String? name,
  }) async {
    await addInquiry(
      customerName: customerName,
      phone: phone,
      email: email,
      message: message,
      eventType: eventType,
      eventDate: eventDate,
      location: location,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getInquiries() {
    return inquiries.orderBy('createdAt', descending: true).snapshots();
  }

  /// Backward-compatible wrapper
  Stream<QuerySnapshot<Map<String, dynamic>>> getContacts() {
    return getInquiries();
  }

  Future<void> deleteInquiry(String docId) async {
    await inquiries.doc(docId).delete();
  }

  /// Backward-compatible wrapper
  Future<void> deleteContact(String docId) async {
    await deleteInquiry(docId);
  }

  Future<void> updateInquiryStatus(String docId, String newStatus) async {
    await inquiries.doc(docId).update({
      'status': newStatus.trim(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Backward-compatible wrapper
  Future<void> updateContactStatus(String docId, String newStatus) async {
    await updateInquiryStatus(docId, newStatus);
  }

  Future<void> updateInquiryNote(String docId, String note) async {
    await inquiries.doc(docId).update({
      'adminNote': note.trim(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Backward-compatible wrapper
  Future<void> updateContactNote(String docId, String note) async {
    await updateInquiryNote(docId, note);
  }

  Future<void> updateInquiry({
    required String docId,
    required String customerName,
    required String phone,
    required String email,
    required String message,
    required String eventType,
    required String eventDate,
    required String location,
  }) async {
    await inquiries.doc(docId).update({
      'customerName': customerName.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'message': message.trim(),
      'eventType': eventType.trim(),
      'eventDate': eventDate.trim(),
      'location': location.trim(),
      'updatedAt': Timestamp.now(),
    });
  }

  /// Backward-compatible wrapper
  Future<void> updateContact({
    required String docId,
    required String customerName,
    required String phone,
    required String email,
    required String message,
    required String eventType,
    required String eventDate,
    required String location,
  }) async {
    await updateInquiry(
      docId: docId,
      customerName: customerName,
      phone: phone,
      email: email,
      message: message,
      eventType: eventType,
      eventDate: eventDate,
      location: location,
    );
  }

  // =========================================================
  // SERVICES
  // =========================================================

  Future<void> addService({
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
    final now = Timestamp.now();

    await services.add({
      'title': title.trim(),
      'description': description.trim(),
      'price': price.trim(),
      'category': category.trim(),

      // homepage / admin polish fields
      'imageUrl': imageUrl.trim(),
      'tag': tag.trim(),
      'isFeatured': isFeatured,
      'isVisible': isVisible,
      'displayOrder': displayOrder,

      'createdAt': now,
      'updatedAt': now,
    });
  }

  /// Admin-facing service stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getServices() {
    return services
        .orderBy('displayOrder')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Public-facing visible services stream for homepage/service previews
  Stream<QuerySnapshot<Map<String, dynamic>>> getVisibleServices() {
    return services
        .where('isVisible', isEqualTo: true)
        .orderBy('displayOrder')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Optional helper if later you want only featured services on homepage
  Stream<QuerySnapshot<Map<String, dynamic>>> getFeaturedVisibleServices() {
    return services
        .where('isVisible', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .orderBy('displayOrder')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateService({
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
    await services.doc(docId).update({
      'title': title.trim(),
      'description': description.trim(),
      'price': price.trim(),
      'category': category.trim(),

      'imageUrl': imageUrl.trim(),
      'tag': tag.trim(),
      'isFeatured': isFeatured,
      'isVisible': isVisible,
      'displayOrder': displayOrder,

      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteService(String docId) async {
    await services.doc(docId).delete();
  }

  Future<void> updateServiceVisibility({
    required String docId,
    required bool isVisible,
  }) async {
    await services.doc(docId).update({
      'isVisible': isVisible,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateServiceFeatured({
    required String docId,
    required bool isFeatured,
  }) async {
    await services.doc(docId).update({
      'isFeatured': isFeatured,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateServiceDisplayOrder({
    required String docId,
    required int displayOrder,
  }) async {
    await services.doc(docId).update({
      'displayOrder': displayOrder,
      'updatedAt': Timestamp.now(),
    });
  }
}
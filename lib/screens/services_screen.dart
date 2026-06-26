import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/responsive_container.dart';
import '../utils/responsive.dart';

class ServicesScreen extends StatelessWidget {
  ServicesScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: const NavBar(),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestoreService.getVisibleServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong while loading services'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                ResponsiveContainer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Our Services',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bridal makeup and beauty services crafted for your special moments.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 28),

                        if (docs.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Text(
                                  'No services available right now.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : 1,
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: isDesktop ? 0.82 : 0.95,
                            ),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data();

                              final title =
                                  (data['title'] ?? '').toString().trim();
                              final description =
                                  (data['description'] ?? '').toString().trim();
                              final price =
                                  (data['price'] ?? '').toString().trim();
                              final category =
                                  (data['category'] ?? '').toString().trim();
                              final imageUrl =
                                  (data['imageUrl'] ?? '').toString().trim();
                              final tag =
                                  (data['tag'] ?? '').toString().trim();
                              final isFeatured =
                                  (data['isFeatured'] ?? false) == true;

                              return _ServiceCard(
                                title: title,
                                description: description,
                                price: price,
                                category: category,
                                imageUrl: imageUrl,
                                tag: tag,
                                isFeatured: isFeatured,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String category;
  final String imageUrl;
  final String tag;
  final bool isFeatured;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.tag,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    final hasTag = tag.isNotEmpty;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE / HEADER
          Stack(
            children: [
              SizedBox(
                height: 210,
                width: double.infinity,
                child: hasImage
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholderImage();
                        },
                      )
                    : _placeholderImage(),
              ),

              if (isFeatured)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade600,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              if (hasTag)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY
                  if (category.isNotEmpty) ...[
                    Text(
                      category,
                      style: TextStyle(
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // TITLE
                  Text(
                    title.isEmpty ? 'Untitled Service' : title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // DESCRIPTION
                  Expanded(
                    child: Text(
                      description.isEmpty
                          ? 'No description available.'
                          : description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // PRICE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      price.isEmpty ? 'Price on request' : '₹$price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
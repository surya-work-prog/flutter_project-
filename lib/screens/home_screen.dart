import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/responsive_container.dart';
import '../utils/responsive.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey heroKey = GlobalKey();
  static final GlobalKey aboutKey = GlobalKey();
  static final GlobalKey servicesKey = GlobalKey();
  static final GlobalKey appointmentKey = GlobalKey();
  static final GlobalKey galleryKey = GlobalKey();
  static final GlobalKey testimonialKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  static void scrollToSection(BuildContext context, String section) {
    GlobalKey? targetKey;

    switch (section) {
      case 'home':
        targetKey = heroKey;
        break;
      case 'about':
        targetKey = aboutKey;
        break;
      case 'services':
        targetKey = servicesKey;
        break;
      case 'appointment':
        targetKey = appointmentKey;
        break;
      case 'gallery':
        targetKey = galleryKey;
        break;
      case 'contact':
        targetKey = contactKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String selectedEventType = 'Bridal Makeup';
  bool isSubmitting = false;

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await _firestoreService.addInquiry(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        message: messageController.text.trim(),
        eventType: selectedEventType,
        eventDate: eventDateController.text.trim(),
        location: locationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inquiry submitted successfully!'),
        ),
      );

      _clearForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit inquiry: $e'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    eventDateController.clear();
    locationController.clear();
    messageController.clear();

    setState(() {
      selectedEventType = 'Bridal Makeup';
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    eventDateController.dispose();
    locationController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    return Scaffold(
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _TopContactBar(),
            const NavBar(),

            _HeroSection(
              key: HomeScreen.heroKey,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            const _HighlightsSection(),

            _AboutSection(
              key: HomeScreen.aboutKey,
              isMobile: isMobile,
            ),

            _ServicesSection(
              key: HomeScreen.servicesKey,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            _AppointmentSection(
              key: HomeScreen.appointmentKey,
              formKey: _formKey,
              nameController: nameController,
              phoneController: phoneController,
              emailController: emailController,
              eventDateController: eventDateController,
              locationController: locationController,
              messageController: messageController,
              selectedEventType: selectedEventType,
              isSubmitting: isSubmitting,
              onEventTypeChanged: (value) {
                setState(() {
                  selectedEventType = value;
                });
              },
              onSubmit: _submitInquiry,
              isMobile: isMobile,
            ),

            const _StatsSection(),

            _GallerySection(
              key: HomeScreen.galleryKey,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            _TestimonialsSection(
              key: HomeScreen.testimonialKey,
              isMobile: isMobile,
              isTablet: isTablet,
            ),

            _ContactSection(
              key: HomeScreen.contactKey,
              isMobile: isMobile,
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _TopContactBar extends StatelessWidget {
  const _TopContactBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: ResponsiveContainer(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: const [
            Text(
              'Call us: +91 98765 43210',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              'Email: thebridaltouch@email.com',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            Text(
              'Bridal • HD • Reception • Party Makeup',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _HeroSection({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double heroHeight = isMobile
        ? 520
        : isTablet
            ? 560
            : 620;

    final double titleSize = isMobile
        ? 30
        : isTablet
            ? 40
            : 54;

    final double subtitleSize = isMobile ? 15 : 18;

    return Container(
      height: heroHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFDF4F5),
            Color(0xFFFBE7EA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ResponsiveContainer(
        child: isMobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _heroText(context, titleSize, subtitleSize, true),
                  const SizedBox(height: 28),
                  _heroImage(),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: _heroText(context, titleSize, subtitleSize, false),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    flex: 5,
                    child: _heroImage(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _heroText(
    BuildContext context,
    double titleSize,
    double subtitleSize,
    bool centered,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Professional Bridal Makeup Artist',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A2C2A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Elegant bridal, engagement, reception and party looks designed to make your special day unforgettable.',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: subtitleSize,
            color: Colors.black87,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: 14,
          runSpacing: 14,
          children: [
            ElevatedButton(
              onPressed: () {
                HomeScreen.scrollToSection(context, 'appointment');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC48A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text('Book Appointment'),
            ),
            OutlinedButton(
              onPressed: () {
                HomeScreen.scrollToSection(context, 'services');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A2C2A),
                side: const BorderSide(color: Color(0xFF4A2C2A)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text('View Services'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heroImage() {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF4DDE1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.face_retouching_natural,
          size: 120,
          color: Color(0xFFC48A8A),
        ),
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _HighlightItem(
        icon: Icons.favorite,
        title: 'Bridal Makeup',
        subtitle: 'Elegant wedding day looks',
      ),
      _HighlightItem(
        icon: Icons.auto_awesome,
        title: 'HD Makeup',
        subtitle: 'Flawless finish for photos',
      ),
      _HighlightItem(
        icon: Icons.spa,
        title: 'Airbrush Makeup',
        subtitle: 'Long-lasting lightweight coverage',
      ),
      _HighlightItem(
        icon: Icons.celebration,
        title: 'Reception & Party',
        subtitle: 'Glam looks for every celebration',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      color: Colors.white,
      child: ResponsiveContainer(
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          alignment: WrapAlignment.center,
          children: items,
        ),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HighlightItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0D7D7)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFF4DDE1),
            child: Icon(icon, color: const Color(0xFFC48A8A)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final bool isMobile;

  const _AboutSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          'ABOUT US',
          style: TextStyle(
            color: Color(0xFFC48A8A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Creating graceful bridal looks with care, detail and elegance',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2C2A),
            height: 1.3,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'At The Bridal Touch, we focus on timeless bridal beauty with looks tailored to your skin tone, outfit, jewellery and event style. From wedding muhurtham looks to reception glam, our goal is to make every bride feel confident and radiant.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.7,
          ),
        ),
        SizedBox(height: 20),
        _AboutBullet(text: 'Bridal, engagement and reception makeup'),
        _AboutBullet(text: 'HD, airbrush and party makeup options'),
        _AboutBullet(text: 'Hair styling, saree draping and event-ready looks'),
      ],
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFCFC),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: isMobile
            ? Column(
                children: [
                  _aboutImage(),
                  const SizedBox(height: 24),
                  textContent,
                ],
              )
            : Row(
                children: [
                  Expanded(child: _aboutImage()),
                  const SizedBox(width: 36),
                  Expanded(child: textContent),
                ],
              ),
      ),
    );
  }

  Widget _aboutImage() {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: const Color(0xFFF4DDE1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(
          Icons.brush,
          size: 110,
          color: Color(0xFFC48A8A),
        ),
      ),
    );
  }
}

class _AboutBullet extends StatelessWidget {
  final String text;

  const _AboutBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFC48A8A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _ServicesSection({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final servicesStream =
        FirebaseFirestore.instance.collection('services').snapshots();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      color: Colors.white,
      child: ResponsiveContainer(
        child: Column(
          children: [
            const Text(
              'OUR SERVICES',
              style: TextStyle(
                color: Color(0xFFC48A8A),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Makeup services for every special event',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Live services loaded from Firestore',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: servicesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Failed to load services: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Text(
                    'No services available yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  );
                }

                final List<Map<String, dynamic>> serviceList = docs
                    .map((doc) {
                      final data = doc.data();

                      return {
                        'title': (data['title'] ?? '').toString(),
                        'description': (data['description'] ?? '').toString(),
                        'price': (data['price'] ?? '').toString(),
                        'category': (data['category'] ?? '').toString(),
                        'tag': (data['tag'] ?? '').toString(),
                        'isFeatured': (data['isFeatured'] ?? false) == true,
                        'isVisible': data['isVisible'] == null
                            ? true
                            : data['isVisible'] == true,
                        'displayOrder':
                            (data['displayOrder'] is int) ? data['displayOrder'] as int : 9999,
                      };
                    })
                    .where((service) => service['isVisible'] == true)
                    .toList();

                serviceList.sort(
                  (a, b) => (a['displayOrder'] as int)
                      .compareTo(b['displayOrder'] as int),
                );

                if (serviceList.isEmpty) {
                  return const Text(
                    'No visible services available yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  );
                }

                final double cardWidth = isMobile
                    ? double.infinity
                    : isTablet
                        ? 260
                        : 280;

                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: serviceList.map((service) {
                    return _ServiceCard(
                      width: cardWidth,
                      title: service['title'] as String,
                      description: service['description'] as String,
                      price: service['price'] as String,
                      category: service['category'] as String,
                      tag: service['tag'] as String,
                      isFeatured: service['isFeatured'] as bool,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final double width;
  final String title;
  final String description;
  final String price;
  final String category;
  final String tag;
  final bool isFeatured;

  const _ServiceCard({
    required this.width,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.tag,
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF4DDE1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                size: 54,
                color: Color(0xFFC48A8A),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (isFeatured)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC48A8A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Featured',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 8),

          if (category.isNotEmpty)
            Text(
              category,
              style: const TextStyle(
                color: Color(0xFFC48A8A),
                fontWeight: FontWeight.w600,
              ),
            ),

          if (tag.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              tag,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 10),
          Text(
            description.isNotEmpty ? description : 'No description available',
            style: const TextStyle(
              color: Colors.black87,
              height: 1.6,
            ),
          ),

          if (price.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Price: $price',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppointmentSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController eventDateController;
  final TextEditingController locationController;
  final TextEditingController messageController;
  final String selectedEventType;
  final bool isSubmitting;
  final ValueChanged<String> onEventTypeChanged;
  final VoidCallback onSubmit;
  final bool isMobile;

  const _AppointmentSection({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.eventDateController,
    required this.locationController,
    required this.messageController,
    required this.selectedEventType,
    required this.isSubmitting,
    required this.onEventTypeChanged,
    required this.onSubmit,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final intro = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          'BOOK APPOINTMENT',
          style: TextStyle(
            color: Color(0xFFC48A8A),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Tell us about your event and bridal requirements',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2C2A),
            height: 1.3,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Share your event date, location and the kind of makeup service you are looking for. We can use this form as your main bridal inquiry section for now.',
          style: TextStyle(
            color: Colors.black87,
            height: 1.7,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 20),
        _ContactPoint(text: 'Wedding, reception, engagement and party makeup'),
        _ContactPoint(text: 'On-location bridal appointments'),
        _ContactPoint(text: 'Quick inquiry response for bookings'),
      ],
    );

    final formCard = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration('Bride Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter bride name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: _inputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedEventType,
                decoration: _inputDecoration('Event Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Bridal Makeup',
                    child: Text('Bridal Makeup'),
                  ),
                  DropdownMenuItem(
                    value: 'Reception Makeup',
                    child: Text('Reception Makeup'),
                  ),
                  DropdownMenuItem(
                    value: 'Engagement Makeup',
                    child: Text('Engagement Makeup'),
                  ),
                  DropdownMenuItem(
                    value: 'Party Makeup',
                    child: Text('Party Makeup'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onEventTypeChanged(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: eventDateController,
                decoration: _inputDecoration('Event Date')
                    .copyWith(hintText: 'e.g. 15 Aug 2026'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter event date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationController,
                decoration: _inputDecoration('Location'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                maxLines: 4,
                decoration: _inputDecoration('Message / Requirements'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC48A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Inquiry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFCFC),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: isMobile
            ? Column(
                children: [
                  intro,
                  const SizedBox(height: 24),
                  formCard,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: intro),
                  const SizedBox(width: 30),
                  Expanded(child: formCard),
                ],
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _ContactPoint extends StatelessWidget {
  final String text;

  const _ContactPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFC48A8A),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    final stats = const [
      _StatItem(number: '500+', label: 'Happy Brides'),
      _StatItem(number: '1000+', label: 'Makeup Looks'),
      _StatItem(number: '8+', label: 'Years Experience'),
      _StatItem(number: '24/7', label: 'Booking Support'),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFC48A8A),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: ResponsiveContainer(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.spaceEvenly,
          children: stats,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _GallerySection({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double imageHeight = isMobile ? 160 : 200;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: Column(
          children: [
            const Text(
              'GALLERY',
              style: TextStyle(
                color: Color(0xFFC48A8A),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recent bridal looks and event makeup work',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Replace these placeholders with Firestore gallery images later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  width: isMobile ? double.infinity : 220,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4DDE1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      'Look ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF4A2C2A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _TestimonialsSection({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final testimonials = const [
      _TestimonialData(
        name: 'Anusha',
        review:
            'Absolutely loved the bridal look. The makeup stayed perfect throughout the event and looked beautiful in photos.',
      ),
      _TestimonialData(
        name: 'Divya',
        review:
            'Very professional and patient. The reception look was exactly what I wanted and the hairstyling completed it beautifully.',
      ),
      _TestimonialData(
        name: 'Sowmya',
        review:
            'The whole experience felt calm and organized. I got so many compliments for my bridal makeup.',
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFCFC),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: Column(
          children: [
            const Text(
              'TESTIMONIALS',
              style: TextStyle(
                color: Color(0xFFC48A8A),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What brides say about us',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: testimonials
                  .map((item) => _TestimonialCard(data: item))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialData {
  final String name;
  final String review;

  const _TestimonialData({
    required this.name,
    required this.review,
  });
}

class _TestimonialCard extends StatelessWidget {
  final _TestimonialData data;

  const _TestimonialCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Color(0xFFC48A8A), size: 34),
          const SizedBox(height: 12),
          Text(
            data.review,
            style: const TextStyle(
              color: Colors.black87,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            data.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final bool isMobile;

  const _ContactSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final infoCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D7)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),
          SizedBox(height: 16),
          _ContactInfoRow(
            icon: Icons.call,
            text: '+91 98765 43210',
          ),
          SizedBox(height: 12),
          _ContactInfoRow(
            icon: Icons.email,
            text: 'thebridaltouch@email.com',
          ),
          SizedBox(height: 12),
          _ContactInfoRow(
            icon: Icons.location_on,
            text: 'Your city / studio address goes here',
          ),
          SizedBox(height: 12),
          _ContactInfoRow(
            icon: Icons.access_time,
            text: 'Mon - Sun : 9:00 AM - 8:00 PM',
          ),
        ],
      ),
    );

    final mapPlaceholder = Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFF4DDE1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'Map / studio location section',
          style: TextStyle(
            color: Color(0xFF4A2C2A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: ResponsiveContainer(
        child: Column(
          children: [
            const Text(
              'CONTACT',
              style: TextStyle(
                color: Color(0xFFC48A8A),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Reach out for bridal bookings and event makeup',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 30),
            isMobile
                ? Column(
                    children: [
                      infoCard,
                      const SizedBox(height: 20),
                      mapPlaceholder,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: infoCard),
                      const SizedBox(width: 24),
                      Expanded(child: mapPlaceholder),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Icon(icon, color: const Color(0xFFC48A8A)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
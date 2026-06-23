import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_container.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final GlobalKey heroKey = GlobalKey();
  static final GlobalKey galleryKey = GlobalKey();
  static final GlobalKey servicesKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static void scrollToSection(BuildContext context, String section) {
    GlobalKey? targetKey;

    switch (section) {
      case 'home':
        targetKey = heroKey;
        break;
      case 'gallery':
        targetKey = galleryKey;
        break;
      case 'services':
        targetKey = servicesKey;
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
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();

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
      await _firestoreService.addContact(
        name: nameController.text.trim(),
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

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      eventDateController.clear();
      locationController.clear();
      messageController.clear();

      setState(() {
        selectedEventType = 'Bridal Makeup';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit inquiry: $e'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
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

    final double heroHeight = isMobile
        ? 260
        : isTablet
            ? 320
            : 380;

    final double titleSize = isMobile
        ? 28
        : isTablet
            ? 38
            : 48;

    final double subtitleSize = isMobile
        ? 14
        : isTablet
            ? 16
            : 18;

    final double imageBoxSize = isMobile
        ? 110
        : isTablet
            ? 140
            : 180;

    final double serviceCardWidth = isMobile
        ? double.infinity
        : isTablet
            ? 220
            : 250;

    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO / HOME SECTION
            Container(
              key: HomeScreen.heroKey,
              width: double.infinity,
              height: heroHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 30, 220, 233),
                    Color.fromARGB(255, 64, 242, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ResponsiveContainer(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'The Bridal Touch',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bridal Makeup Artist & Beauty Studio',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: subtitleSize,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text("Admin Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BODY CONTENT
            ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // GALLERY SECTION
                  Container(
                    key: HomeScreen.galleryKey,
                    child: const Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _imageBox('Look 1', imageBoxSize),
                      _imageBox('Look 2', imageBoxSize),
                      _imageBox('Look 3', imageBoxSize),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // SERVICES SECTION
                  Container(
                    key: HomeScreen.servicesKey,
                    child: const Text(
                      'Our Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _ServiceCard(
                        title: 'Bridal Makeup',
                        width: serviceCardWidth,
                      ),
                      _ServiceCard(
                        title: 'HD Makeup',
                        width: serviceCardWidth,
                      ),
                      _ServiceCard(
                        title: 'Party Makeup',
                        width: serviceCardWidth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // CONTACT / INQUIRY SECTION
                  Container(
                    key: HomeScreen.contactKey,
                    child: const Text(
                      'Book Your Bridal Inquiry',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Bride Name',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Event Type',
                                border: OutlineInputBorder(),
                              ),
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
                                  setState(() {
                                    selectedEventType = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: eventDateController,
                              decoration: const InputDecoration(
                                labelText: 'Event Date',
                                hintText: 'e.g. 15 Aug 2026',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
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
                              decoration: const InputDecoration(
                                labelText: 'Message / Requirements',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your message';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : _submitInquiry,
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Submit Inquiry'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            const Footer(),
          ],
        ),
      ),
    );
  }
}

// IMAGE BOX
Widget _imageBox(String text, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.pinkAccent.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

// SERVICE CARD
class _ServiceCard extends StatelessWidget {
  final String title;
  final double width;

  const _ServiceCard({
    required this.title,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink),
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
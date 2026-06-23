import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/footer.dart';
import '../widgets/responsive_container.dart';
import '../services/firestore_service.dart';
import '../utils/responsive.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitForm() async {
    try {
      await _firestoreService.addContact(
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
        phone: '', eventType: '', eventDate: '', location: '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully!'),
        ),
      );

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      debugPrint('Firestore write successful');
    } catch (e) {
      debugPrint('Firestore Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: const NavBar(),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ResponsiveContainer(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    'Contact Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 700 : 500,
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: _messageController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
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
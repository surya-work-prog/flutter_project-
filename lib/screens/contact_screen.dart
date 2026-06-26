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
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String _selectedEventType = 'Bridal Makeup';
  DateTime? _selectedEventDate;
  bool _isSubmitting = false;

  final List<String> _eventTypes = [
    'Bridal Makeup',
    'Engagement',
    'Reception',
    'Party Makeup',
    'HD Makeup',
    'Hairstyling',
    'Saree Draping',
    'Other',
  ];

  Future<void> _pickEventDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? now,
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedEventDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select event date')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firestoreService.addContact(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
        eventType: _selectedEventType,
        eventDate: _formatDate(_selectedEventDate!),
        location: _locationController.text.trim(), name: '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inquiry submitted successfully!'),
        ),
      );

      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _locationController.clear();
      _messageController.clear();

      setState(() {
        _selectedEventType = 'Bridal Makeup';
        _selectedEventDate = null;
      });
    } catch (e) {
      debugPrint('Firestore Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
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
                    'Book Your Makeup Appointment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Fill out the inquiry form and we will contact you soon.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 700 : 500,
                      ),
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Customer Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                DropdownButtonFormField<String>(
                                  value: _selectedEventType,
                                  decoration: const InputDecoration(
                                    labelText: 'Event Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _eventTypes.map((event) {
                                    return DropdownMenuItem(
                                      value: event,
                                      child: Text(event),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedEventType = value;
                                      });
                                    }
                                  },
                                ),

                                const SizedBox(height: 15),

                                InkWell(
                                  onTap: _pickEventDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Event Date',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedEventDate == null
                                              ? 'Select event date'
                                              : _formatDate(_selectedEventDate!),
                                          style: TextStyle(
                                            color: _selectedEventDate == null
                                                ? Colors.grey.shade700
                                                : Colors.black,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Event Location',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter event location';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                TextFormField(
                                  controller: _messageController,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Message / Requirements / Package Details',
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
                                    onPressed: _isSubmitting ? null : _submitForm,
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
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
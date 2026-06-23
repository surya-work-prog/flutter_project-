import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
import '../widgets/navbar.dart';
import '../widgets/responsive_container.dart';
import '../utils/responsive.dart';

import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../providers/contact_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late TabController _tabController;

  // =========================
  // SERVICE FORM CONTROLLERS
  // =========================
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String selectedCategory = 'Bridal';

  final List<String> categories = [
    'Bridal',
    'HD Makeup',
    'Party Makeup',
    'Reception',
    'Engagement',
    'Hairstyling',
    'Saree Draping',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // =========================
  // CONTACT METHODS
  // =========================
  void _showEditNoteDialog(String docId, String currentNote) {
    final TextEditingController noteController =
        TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Admin Note"),
          content: TextField(
            controller: noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Enter admin note",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final contactProvider = context.read<ContactProvider>();

                final success = await contactProvider.updateContactNote(
                  docId: docId,
                  note: noteController.text.trim(),
                );

                if (!mounted) return;

                if (success) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Note updated successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        contactProvider.errorMessage ??
                            "Failed to update note",
                      ),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteContact(String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Inquiry"),
          content: const Text("Are you sure you want to delete this inquiry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final contactProvider = context.read<ContactProvider>();

                final success = await contactProvider.deleteContact(docId);

                if (!mounted) return;

                if (success) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Inquiry deleted")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        contactProvider.errorMessage ??
                            "Failed to delete inquiry",
                      ),
                    ),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // SERVICE METHODS
  // =========================
  Future<void> _addService() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all service fields")),
      );
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();

    final success = await serviceProvider.addService(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      category: selectedCategory,
    );

    if (!mounted) return;

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();

      setState(() {
        selectedCategory = 'Bridal';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service added successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            serviceProvider.errorMessage ?? "Failed to add service",
          ),
        ),
      );
    }
  }

  void _showEditServiceDialog({
    required String docId,
    required String currentTitle,
    required String currentDescription,
    required String currentPrice,
    required String currentCategory,
  }) {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController =
        TextEditingController(text: currentDescription);
    final priceController = TextEditingController(text: currentPrice);

    String editCategory = currentCategory;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Service"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Service Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: editCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              editCategory = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final serviceProvider = context.read<ServiceProvider>();

                    final success = await serviceProvider.updateService(
                      docId: docId,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: priceController.text.trim(),
                      category: editCategory,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Service updated successfully"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            serviceProvider.errorMessage ??
                                "Failed to update service",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteService(String docId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Service"),
          content: const Text("Are you sure you want to delete this service?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final serviceProvider = context.read<ServiceProvider>();

                final success = await serviceProvider.deleteService(docId);

                if (!mounted) return;

                if (success) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Service deleted")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        serviceProvider.errorMessage ??
                            "Failed to delete service",
                      ),
                    ),
                  );
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // CONTACT TAB
  // =========================
  Widget _buildContactsTab() {
    final bool isDesktop = Responsive.isDesktop(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No inquiries found"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final name = data['name'] ?? '';
            final phone = data['phone'] ?? '';
            final email = data['email'] ?? '';
            final message = data['message'] ?? '';
            final eventType = data['eventType'] ?? 'Not provided';
            final eventDate = data['eventDate'] ?? 'Not provided';
            final location = data['location'] ?? 'Not provided';
            final status = data['status'] ?? 'pending';
            final adminNote = data['adminNote'] ?? '';

            final bool isDone = status == 'done';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: isDone
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // BASIC INFO
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _infoItem("Phone", phone),
                        _infoItem("Email", email),
                        _infoItem("Event Type", eventType),
                        _infoItem("Event Date", eventDate),
                        _infoItem("Location", location),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // MESSAGE
                    const Text(
                      "Message / Requirements",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        message.isEmpty ? "No message provided" : message,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ADMIN NOTE
                    if (adminNote.toString().trim().isNotEmpty) ...[
                      const Text(
                        "Admin Note",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueGrey.shade100),
                        ),
                        child: Text(adminNote),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ACTION BUTTONS
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final newStatus = isDone ? 'pending' : 'done';
                            final contactProvider =
                                context.read<ContactProvider>();

                            final success =
                                await contactProvider.updateContactStatus(
                              docId: doc.id,
                              status: newStatus,
                            );

                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Status changed to ${newStatus.toUpperCase()}",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    contactProvider.errorMessage ??
                                        "Failed to update status",
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isDone ? Icons.refresh : Icons.check_circle,
                            size: 18,
                          ),
                          label: Text(isDone ? "Mark Pending" : "Mark Done"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            _showEditNoteDialog(doc.id, adminNote);
                          },
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: const Text("Edit Note"),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            _confirmDeleteContact(doc.id);
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text("Delete"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    if (isDesktop) const SizedBox(height: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoItem(String label, String value) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Not provided' : value),
        ],
      ),
    );
  }

  // =========================
  // SERVICES TAB
  // =========================
  Widget _buildServicesTab() {
    final bool isDesktop = Responsive.isDesktop(context);
    final serviceProvider = context.watch<ServiceProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 700 : 550,
              ),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Add New Service",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Service Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: serviceProvider.isLoading
                              ? null
                              : _addService,
                          child: serviceProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Add Service"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "All Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getServices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No services found"),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = data['title'] ?? '';
                  final description = data['description'] ?? '';
                  final price = data['price'] ?? '';
                  final category = data['category'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(description),
                          const SizedBox(height: 8),
                          Text("Price: ₹$price"),
                          Text("Category: $category"),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showEditServiceDialog(
                                    docId: doc.id,
                                    currentTitle: title,
                                    currentDescription: description,
                                    currentPrice: price,
                                    currentCategory: category,
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _confirmDeleteService(doc.id);
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text("Delete"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // MAIN BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Back to Home',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Inquiries"),
            Tab(text: "Services"),
          ],
        ),
      ),
      endDrawer: const AppDrawer(),
      body: ResponsiveContainer(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildContactsTab(),
            _buildServicesTab(),
          ],
        ),
      ),
    );
  }
}
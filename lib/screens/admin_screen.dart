import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
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
  // FIRESTORE STREAMS
  // =========================
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _contactsStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _servicesStream;

  // =========================
  // ADD SERVICE FORM CONTROLLERS
  // =========================
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _displayOrderController =
      TextEditingController(text: '0');

  bool _isFeatured = false;
  bool _isVisible = true;

  // =========================
  // INQUIRY DASHBOARD CONTROLLERS
  // =========================
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  String _searchQuery = '';
  String _statusFilter = 'All';
  String _eventTypeFilter = 'All';
  String _sortOption = 'Newest First';

  final List<String> _statusOptions = const [
    'All',
    'New',
    'Contacted',
    'Booked',
    'Completed',
    'Cancelled',
  ];

  final List<String> _sortOptions = const [
    'Newest First',
    'Oldest First',
    'Event Date',
  ];

  final List<String> _statusUpdateOptions = const [
    'new',
    'contacted',
    'booked',
    'completed',
    'cancelled',
  ];

  String selectedCategory = 'Bridal';

  final List<String> categories = const [
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

    _contactsStream = _firestoreService.getContacts();
    _servicesStream = _firestoreService.getServices();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      final newValue = _searchController.text.trim().toLowerCase();

      if (newValue != _searchQuery && mounted) {
        setState(() {
          _searchQuery = newValue;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _tagController.dispose();
    _displayOrderController.dispose();

    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

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
        const SnackBar(
          content: Text("Please fill title, description and price"),
        ),
      );
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();
    final displayOrder =
        int.tryParse(_displayOrderController.text.trim()) ?? 0;

    final success = await serviceProvider.addService(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: _priceController.text.trim(),
      category: selectedCategory,
      imageUrl: _imageUrlController.text.trim(),
      tag: _tagController.text.trim(),
      isFeatured: _isFeatured,
      isVisible: _isVisible,
      displayOrder: displayOrder,
    );

    if (!mounted) return;

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _tagController.clear();
      _displayOrderController.text = '0';

      setState(() {
        selectedCategory = 'Bridal';
        _isFeatured = false;
        _isVisible = true;
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
    required String currentImageUrl,
    required String currentTag,
    required bool currentIsFeatured,
    required bool currentIsVisible,
    required int currentDisplayOrder,
  }) {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController =
        TextEditingController(text: currentDescription);
    final priceController = TextEditingController(text: currentPrice);
    final imageUrlController = TextEditingController(text: currentImageUrl);
    final tagController = TextEditingController(text: currentTag);
    final displayOrderController =
        TextEditingController(text: currentDisplayOrder.toString());

    String editCategory = currentCategory;
    bool editFeatured = currentIsFeatured;
    bool editVisible = currentIsVisible;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Service"),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
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
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: "Image URL (optional)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tagController,
                        decoration: const InputDecoration(
                          labelText: "Tag (optional)",
                          hintText: "Popular / Best Seller / Bridal Favourite",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: displayOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Display Order",
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
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: editFeatured,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Featured Service"),
                        onChanged: (value) {
                          setDialogState(() {
                            editFeatured = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        value: editVisible,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Visible on website"),
                        onChanged: (value) {
                          setDialogState(() {
                            editVisible = value;
                          });
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
                    if (titleController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Title, description and price are required",
                          ),
                        ),
                      );
                      return;
                    }

                    final serviceProvider = context.read<ServiceProvider>();
                    final displayOrder =
                        int.tryParse(displayOrderController.text.trim()) ?? 0;

                    final success = await serviceProvider.updateService(
                      docId: docId,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: priceController.text.trim(),
                      category: editCategory,
                      imageUrl: imageUrlController.text.trim(),
                      tag: tagController.text.trim(),
                      isFeatured: editFeatured,
                      isVisible: editVisible,
                      displayOrder: displayOrder,
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
  // HELPERS
  // =========================
  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue.shade100;
      case 'contacted':
        return Colors.orange.shade100;
      case 'booked':
        return Colors.purple.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue.shade800;
      case 'contacted':
        return Colors.orange.shade800;
      case 'booked':
        return Colors.purple.shade800;
      case 'completed':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);

    return null;
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardControls(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final eventTypes = <String>{};

    for (final doc in docs) {
      final data = doc.data();
      final eventType = (data['eventType'] ?? '').toString().trim();
      if (eventType.isNotEmpty) {
        eventTypes.add(eventType);
      }
    }

    final eventTypeOptions = ['All', ...eventTypes.toList()..sort()];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search inquiries',
                hintText: 'Search by customer name, phone or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && value != _statusFilter) {
                        setState(() {
                          _statusFilter = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: eventTypeOptions.contains(_eventTypeFilter)
                        ? _eventTypeFilter
                        : 'All',
                    decoration: const InputDecoration(
                      labelText: 'Filter by Event Type',
                      border: OutlineInputBorder(),
                    ),
                    items: eventTypeOptions.map((eventType) {
                      return DropdownMenuItem<String>(
                        value: eventType,
                        child: Text(eventType),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && value != _eventTypeFilter) {
                        setState(() {
                          _eventTypeFilter = value;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    value: _sortOption,
                    decoration: const InputDecoration(
                      labelText: 'Sort',
                      border: OutlineInputBorder(),
                    ),
                    items: _sortOptions.map((sort) {
                      return DropdownMenuItem<String>(
                        value: sort,
                        child: Text(sort),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null && value != _sortOption) {
                        setState(() {
                          _sortOption = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
  // CONTACT TAB
  // =========================
  Widget _buildContactsTab() {
    final bool isDesktop = Responsive.isDesktop(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _contactsStream,
      builder: (context, contactSnapshot) {
        if (contactSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!contactSnapshot.hasData || contactSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No inquiries found"));
        }

        final allDocs = contactSnapshot.data!.docs;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _servicesStream,
          builder: (context, serviceSnapshot) {
            final totalServices = serviceSnapshot.data?.docs.length ?? 0;

            final totalInquiries = allDocs.length;
            int newCount = 0;
            int contactedCount = 0;
            int bookedCount = 0;
            int completedCount = 0;

            for (final doc in allDocs) {
              final data = doc.data();
              final status =
                  (data['status'] ?? 'new').toString().toLowerCase().trim();

              switch (status) {
                case 'new':
                  newCount++;
                  break;
                case 'contacted':
                  contactedCount++;
                  break;
                case 'booked':
                  bookedCount++;
                  break;
                case 'completed':
                  completedCount++;
                  break;
              }
            }

            List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs =
                allDocs.where((doc) {
              final data = doc.data();

              final customerName =
                  (data['customerName'] ?? data['name'] ?? '')
                      .toString()
                      .toLowerCase();
              final phone = (data['phone'] ?? '').toString().toLowerCase();
              final email = (data['email'] ?? '').toString().toLowerCase();
              final status =
                  (data['status'] ?? 'new').toString().toLowerCase().trim();
              final eventType =
                  (data['eventType'] ?? '').toString().trim().toLowerCase();

              final matchesSearch = _searchQuery.isEmpty ||
                  customerName.contains(_searchQuery) ||
                  phone.contains(_searchQuery) ||
                  email.contains(_searchQuery);

              final matchesStatus = _statusFilter == 'All' ||
                  status == _statusFilter.toLowerCase();

              final matchesEventType = _eventTypeFilter == 'All' ||
                  eventType == _eventTypeFilter.toLowerCase();

              return matchesSearch && matchesStatus && matchesEventType;
            }).toList();

            filteredDocs.sort((a, b) {
              final dataA = a.data();
              final dataB = b.data();

              if (_sortOption == 'Oldest First') {
                final aCreated = _parseDate(dataA['createdAt']) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                final bCreated = _parseDate(dataB['createdAt']) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                return aCreated.compareTo(bCreated);
              }

              if (_sortOption == 'Event Date') {
                final aEvent = _parseDate(dataA['eventDate']) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                final bEvent = _parseDate(dataB['eventDate']) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
                return aEvent.compareTo(bEvent);
              }

              final aCreated = _parseDate(dataA['createdAt']) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final bCreated = _parseDate(dataB['createdAt']) ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return bCreated.compareTo(aCreated);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(
                        title: 'Total Inquiries',
                        value: totalInquiries.toString(),
                        color: Colors.indigo,
                        icon: Icons.inbox,
                      ),
                      _buildStatCard(
                        title: 'New',
                        value: newCount.toString(),
                        color: Colors.blue,
                        icon: Icons.fiber_new,
                      ),
                      _buildStatCard(
                        title: 'Contacted',
                        value: contactedCount.toString(),
                        color: Colors.orange,
                        icon: Icons.call,
                      ),
                      _buildStatCard(
                        title: 'Booked',
                        value: bookedCount.toString(),
                        color: Colors.purple,
                        icon: Icons.event_available,
                      ),
                      _buildStatCard(
                        title: 'Completed',
                        value: completedCount.toString(),
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                      _buildStatCard(
                        title: 'Total Services',
                        value: totalServices.toString(),
                        color: Colors.teal,
                        icon: Icons.design_services,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildDashboardControls(allDocs),

                  const SizedBox(height: 4),
                  Text(
                    'Showing ${filteredDocs.length} inquiry${filteredDocs.length == 1 ? '' : 'ies'}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (filteredDocs.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No inquiries match the current filters'),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data();

                        final customerName =
                            (data['customerName'] ?? data['name'] ?? '')
                                .toString();
                        final phone = (data['phone'] ?? '').toString();
                        final email = (data['email'] ?? '').toString();
                        final message = (data['message'] ?? '').toString();
                        final eventType =
                            (data['eventType'] ?? 'Not provided').toString();
                        final eventDate =
                            (data['eventDate'] ?? 'Not provided').toString();
                        final location =
                            (data['location'] ?? 'Not provided').toString();
                        final status =
                            (data['status'] ?? 'new').toString().toLowerCase();
                        final adminNote =
                            (data['adminNote'] ?? '').toString();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        customerName.isEmpty
                                            ? 'Unnamed Inquiry'
                                            : customerName,
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
                                        color: _statusBgColor(status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _capitalize(status).toUpperCase(),
                                        style: TextStyle(
                                          color: _statusTextColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

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
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    message.isEmpty
                                        ? "No message provided"
                                        : message,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                if (adminNote.trim().isNotEmpty) ...[
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
                                      border: Border.all(
                                        color: Colors.blueGrey.shade100,
                                      ),
                                    ),
                                    child: Text(adminNote),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: isDesktop ? 220 : double.infinity,
                                      child: DropdownButtonFormField<String>(
                                        value: _statusUpdateOptions.contains(status)
                                            ? status
                                            : 'new',
                                        decoration: const InputDecoration(
                                          labelText: 'Update Status',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        items: _statusUpdateOptions.map((value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(_capitalize(value)),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          if (value == null) return;

                                          final contactProvider =
                                              context.read<ContactProvider>();

                                          final success = await contactProvider
                                              .updateContactStatus(
                                            docId: doc.id,
                                            status: value,
                                          );

                                          if (!mounted) return;

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? "Status updated to ${value.toUpperCase()}"
                                                    : (contactProvider.errorMessage ??
                                                        "Failed to update status"),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
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
                maxWidth: isDesktop ? 800 : 560,
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
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: "Image URL (optional)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: "Tag (optional)",
                          hintText: "Popular / Best Seller / Bridal Favourite",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _displayOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Display Order",
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
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Featured Service"),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Visible on website"),
                        value: _isVisible,
                        onChanged: (value) {
                          setState(() {
                            _isVisible = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              serviceProvider.isLoading ? null : _addService,
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
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _servicesStream,
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
                  final data = doc.data();

                  final title = (data['title'] ?? '').toString();
                  final description = (data['description'] ?? '').toString();
                  final price = (data['price'] ?? '').toString();
                  final category = (data['category'] ?? '').toString();
                  final imageUrl = (data['imageUrl'] ?? '').toString();
                  final tag = (data['tag'] ?? '').toString();
                  final isFeatured = data['isFeatured'] == true;
                  final isVisible = data['isVisible'] != false;
                  final displayOrder = (data['displayOrder'] ?? 0) is int
                      ? data['displayOrder'] as int
                      : int.tryParse('${data['displayOrder']}') ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    height: 180,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Text("Image not available"),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (isFeatured)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'FEATURED',
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(description),
                          const SizedBox(height: 10),
                          Text(
                            "Price: ₹$price",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(label: Text(category)),
                              if (tag.trim().isNotEmpty) Chip(label: Text(tag)),
                              Chip(
                                label: Text(isVisible ? 'Visible' : 'Hidden'),
                                backgroundColor: isVisible
                                    ? Colors.green.shade50
                                    : Colors.grey.shade300,
                              ),
                              Chip(
                                label: Text('Order: $displayOrder'),
                              ),
                            ],
                          ),
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
                                    currentCategory:
                                        category.isEmpty ? 'Bridal' : category,
                                    currentImageUrl: imageUrl,
                                    currentTag: tag,
                                    currentIsFeatured: isFeatured,
                                    currentIsVisible: isVisible,
                                    currentDisplayOrder: displayOrder,
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final success = await context
                                      .read<ServiceProvider>()
                                      .updateServiceFeatured(
                                        docId: doc.id,
                                        isFeatured: !isFeatured,
                                      );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? (isFeatured
                                                ? 'Service removed from featured'
                                                : 'Service marked as featured')
                                            : (context
                                                    .read<ServiceProvider>()
                                                    .errorMessage ??
                                                'Failed to update featured status'),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  isFeatured ? Icons.star_border : Icons.star,
                                  size: 18,
                                ),
                                label: Text(
                                  isFeatured ? "Unfeature" : "Feature",
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final success = await context
                                      .read<ServiceProvider>()
                                      .updateServiceVisibility(
                                        docId: doc.id,
                                        isVisible: !isVisible,
                                      );

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? (isVisible
                                                ? 'Service hidden from website'
                                                : 'Service made visible on website')
                                            : (context
                                                    .read<ServiceProvider>()
                                                    .errorMessage ??
                                                'Failed to update visibility'),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  isVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                ),
                                label: Text(
                                  isVisible ? "Hide" : "Show",
                                ),
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedContacts = [];
  int _step = 0; // 0 = select contacts, 1 = group metadata

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 0 ? 'New Group' : 'Group Info',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_step == 0)
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: Text(
                'Next',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _step == 0 ? _buildContactPicker(colorScheme) : _buildGroupMetadata(colorScheme),
    );
  }

  Widget _buildContactPicker(ColorScheme colorScheme) {
    final mockContacts = ['Alice Smith', 'Bob Jones', 'Charlie Brown', 'Diana Prince'];
    
    return Column(
      children: [
        // Selected chips
        if (_selectedContacts.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedContacts.map((name) {
                return Chip(
                  label: Text(name, style: TextStyle(color: colorScheme.onSurface, fontSize: 13)),
                  deleteIcon: Icon(Icons.close, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                  onDeleted: () => setState(() => _selectedContacts.remove(name)),
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(color: colorScheme.onSurface.withOpacity(0.1)),
                );
              }).toList(),
            ),
          ),
        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.4), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
          ),
        ),
        // Contact List
        Expanded(
          child: ListView.builder(
            itemCount: mockContacts.length,
            itemBuilder: (context, index) {
              final name = mockContacts[index];
              final isSelected = _selectedContacts.contains(name);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: Text(name[0], style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(name, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
                subtitle: Text('Last seen recently', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : Icon(Icons.circle_outlined, color: colorScheme.onSurface.withOpacity(0.2)),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedContacts.remove(name);
                    } else {
                      _selectedContacts.add(name);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupMetadata(ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        // Group photo
        Center(
          child: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: colorScheme.surface,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.camera_alt_outlined, color: colorScheme.onSurface),
                        title: Text('Take Photo', style: TextStyle(color: colorScheme.onSurface)),
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          final status = await Permission.camera.request();
                          if (status.isGranted) {
                            Navigator.pop(ctx);
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera permission required')));
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_library_outlined, color: colorScheme.onSurface),
                        title: Text('Choose from Gallery', style: TextStyle(color: colorScheme.onSurface)),
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.surface,
              child: Icon(Icons.camera_alt, color: colorScheme.onSurface.withOpacity(0.5), size: 32),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Group name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Group name',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
              border: InputBorder.none,
            ),
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        // Members count
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                '${_selectedContacts.length} members selected',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Create button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _nameController.text.trim().isNotEmpty ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Group "${_nameController.text}" created successfully!')),
              );
              Navigator.pop(context);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Create Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

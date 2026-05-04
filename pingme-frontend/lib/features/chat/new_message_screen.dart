import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  bool _isLoading = true;
  bool _hasPermission = false;
  // Mocking "contacts using Ping Me" list. 
  // In a real app, you would fetch device contacts and check them against your backend.
  final List<Map<String, String>> _pingMeContacts = []; 

  @override
  void initState() {
    super.initState();
    _checkContactsPermission();
  }

  Future<void> _checkContactsPermission() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestContacts() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        // Mock loading some contacts
        _pingMeContacts.clear(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Message',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search people by username',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                    ),
                  ),
                ),

                // Action Tiles (Group / Channel)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.group,
                          iconColor: Colors.blueAccent,
                          label: 'New Group',
                          colorScheme: colorScheme,
                          onTap: () => Navigator.pushNamed(context, '/create_group'),
                        ),
                        Divider(height: 1, color: colorScheme.background),
                        _ActionTile(
                          icon: Icons.campaign,
                          iconColor: Colors.greenAccent,
                          label: 'New Channel',
                          colorScheme: colorScheme,
                          onTap: () => Navigator.pushNamed(context, '/create_channel'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contacts List or Empty State
                Expanded(
                  child: (_hasPermission && _pingMeContacts.isNotEmpty)
                      ? _buildContactsList(colorScheme)
                      : _buildEmptyState(colorScheme),
                ),
              ],
            ),
    );
  }

  Widget _buildContactsList(ColorScheme colorScheme) {
    return ListView.builder(
      itemCount: _pingMeContacts.length,
      itemBuilder: (context, index) {
        final contact = _pingMeContacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Text(contact['name']![0], style: TextStyle(color: colorScheme.primary)),
          ),
          title: Text(contact['name']!, style: TextStyle(color: colorScheme.onSurface)),
          subtitle: Text('last seen recently', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Placeholder
          Icon(
            Icons.person_search_rounded,
            size: 100,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Add Contacts',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You have no contacts on Ping Me yet.\nHow about adding them?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_hasPermission) {
                  _requestContacts();
                } else {
                  // Add new contact logic
                }
              },
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text('New Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

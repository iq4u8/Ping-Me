import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../presentation/viewmodels/chat_viewmodel.dart';
import '../../presentation/viewmodels/theme_viewmodel.dart';

class ChatListScreen extends StatefulWidget {
  final Function(int)? onTabSwitch;

  const ChatListScreen({super.key, this.onTabSwitch});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      endDrawer: _ChatListEndDrawer(onTabSwitch: widget.onTabSwitch),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Text(
                    'Ping Me',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.folder_outlined, color: colorScheme.onSurface, size: 20),
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat_folders');
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.more_vert, color: colorScheme.onSurface, size: 20),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.4), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                ),
              ),
            ),

            // ── Filter Chips ──
            SizedBox(
              height: 36,
              child: Builder(
                builder: (context) {
                  final allFilters = ['All', ...chatVM.folders];
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ...List.generate(allFilters.length, (index) {
                        final isSelected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.15),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  allFilters[index],
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.45),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () {
                          _showCreateFolderDialog(context, chatVM);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.onSurface.withOpacity(0.15)),
                          ),
                          child: Icon(Icons.add, color: colorScheme.onSurface.withOpacity(0.45), size: 16),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),

            const SizedBox(height: 4),

            // ── Chat List ──
            Expanded(
              child: chatVM.isLoading
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await chatVM.loadConversations();
                      },
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.surface,
                      child: ListView.builder(
                        itemCount: chatVM.conversations.length,
                        itemBuilder: (context, index) {
                          final conv = chatVM.conversations[index];
                          return ChatListItem(
                            name: conv.name,
                            lastMsg: conv.lastMessage,
                            time: TimeOfDay.now().format(context), // Auto detects 12/24 hour format
                            unread: index == 0,
                            onClick: () => Navigator.pushNamed(
                              context,
                              '/conversation',
                              arguments: conv.name,
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      // ── FAB ──
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: const _AnimatedFAB(),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, ChatViewModel chatVM) {
    final TextEditingController controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create Folder', style: TextStyle(color: colorScheme.onSurface)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Folder Name',
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  chatVM.addFolder(controller.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text('Create', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedFAB extends StatefulWidget {
  const _AnimatedFAB();

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.pushNamed(context, '/new_message');
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.edit, color: colorScheme.onPrimary, size: 20),
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String name;
  final String lastMsg;
  final String time;
  final bool unread;
  final VoidCallback onClick;

  const ChatListItem({
    super.key,
    required this.name,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: unread ? FontWeight.bold : FontWeight.w500,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: unread ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMsg,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatListEndDrawer extends StatelessWidget {
  final Function(int)? onTabSwitch;

  const _ChatListEndDrawer({this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.75,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 60), // Leaves space at bottom
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.4),
              border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header (Profile Info) ──
              Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.1), width: 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                          child: Icon(Icons.person, color: colorScheme.primary, size: 24),
                        ),
                        Column(
                          children: [
                            Consumer<ThemeViewModel>(
                              builder: (context, themeVM, _) {
                                IconData themeIcon = Icons.brightness_auto;
                                if (themeVM.currentMode == AppThemeMode.light) {
                                  themeIcon = Icons.light_mode;
                                } else if (themeVM.currentMode == AppThemeMode.dark) {
                                  themeIcon = Icons.dark_mode;
                                }
                                return IconButton(
                                  icon: Icon(themeIcon, color: colorScheme.onSurface, size: 20),
                                  onPressed: () => themeVM.cycleTheme(),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: Icon(Icons.bookmark_border, color: colorScheme.onSurface, size: 20),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/saved_messages');
                              },
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ping Me',
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+91 xxxxxxxxxx',
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                        Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Options List ──
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  children: [
                    _DrawerTile(icon: Icons.add, label: 'Add Account', colorScheme: colorScheme),
                    Divider(color: colorScheme.onSurface.withOpacity(0.1)),
                    _DrawerTile(
                      icon: Icons.person_outline, 
                      label: 'My Profile', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        onTabSwitch?.call(3);
                      },
                    ),
                    Divider(color: colorScheme.onSurface.withOpacity(0.1)),
                    _DrawerTile(
                      icon: Icons.group_outlined, 
                      label: 'New Group', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/create_group');
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.campaign_outlined, 
                      label: 'New Channel', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/create_channel');
                      },
                    ),
                    Divider(color: colorScheme.onSurface.withOpacity(0.1)),
                    _DrawerTile(
                      icon: Icons.person_search_outlined, 
                      label: 'Contacts', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        onTabSwitch?.call(1);
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.folder_outlined, 
                      label: 'Chat Folders', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/chat_folders');
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.bookmark_border, 
                      label: 'Saved Messages', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/saved_messages');
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.call_outlined, 
                      label: 'Calls', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/call_history');
                      },
                    ),
                    _DrawerTile(
                      icon: Icons.settings_outlined, 
                      label: 'Settings', 
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.pop(context);
                        onTabSwitch?.call(2);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _DrawerTile({required this.icon, required this.label, required this.colorScheme, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface.withOpacity(0.8), size: 20),
      title: Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap ?? () => Navigator.pop(context),
      horizontalTitleGap: 12,
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
    );
  }
}

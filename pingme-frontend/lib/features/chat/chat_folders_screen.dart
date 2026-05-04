import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/viewmodels/chat_viewmodel.dart';

class ChatFoldersScreen extends StatefulWidget {
  const ChatFoldersScreen({super.key});

  @override
  State<ChatFoldersScreen> createState() => _ChatFoldersScreenState();
}

class _ChatFoldersScreenState extends State<ChatFoldersScreen> {
  void _showFolderDialog(BuildContext context, ChatViewModel chatVM, {int? indexToEdit, String? currentName}) {
    final TextEditingController controller = TextEditingController(text: currentName);
    final colorScheme = Theme.of(context).colorScheme;
    
    // Mock selection state
    bool incDirect = true;
    bool incGroups = false;
    bool incChannels = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(indexToEdit == null ? 'Create Category' : 'Edit Category', style: TextStyle(color: colorScheme.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Category Name',
                        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Included Chats', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: Text('Direct Chats', style: TextStyle(color: colorScheme.onSurface)),
                      value: incDirect,
                      activeColor: colorScheme.primary,
                      onChanged: (v) => setStateDialog(() => incDirect = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: Text('Groups', style: TextStyle(color: colorScheme.onSurface)),
                      value: incGroups,
                      activeColor: colorScheme.primary,
                      onChanged: (v) => setStateDialog(() => incGroups = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: Text('Channels', style: TextStyle(color: colorScheme.onSurface)),
                      value: incChannels,
                      activeColor: colorScheme.primary,
                      onChanged: (v) => setStateDialog(() => incChannels = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
                ),
                TextButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      if (indexToEdit == null) {
                        chatVM.addFolder(text);
                      } else {
                        chatVM.renameFolder(indexToEdit, text);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Save', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showOptions(BuildContext context, ChatViewModel chatVM, int index, String name) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: colorScheme.onSurface),
              title: Text('Rename', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showFolderDialog(context, chatVM, indexToEdit: index, currentName: name);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                chatVM.removeFolder(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
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
          'Chat Categories',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.onSurface),
            onPressed: () => _showFolderDialog(context, chatVM),
          )
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: chatVM.folders.length,
        onReorder: (oldIndex, newIndex) {
          chatVM.reorderFolders(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final folderName = chatVM.folders[index];
          return ListTile(
            key: ValueKey(folderName),
            tileColor: colorScheme.background,
            leading: Icon(Icons.drag_handle, color: colorScheme.onSurface.withOpacity(0.4)),
            title: Text(
              folderName,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
            trailing: IconButton(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface.withOpacity(0.6)),
              onPressed: () => _showOptions(context, chatVM, index, folderName),
            ),
            onTap: () => _showOptions(context, chatVM, index, folderName),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: () => _showFolderDialog(context, chatVM),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }
}

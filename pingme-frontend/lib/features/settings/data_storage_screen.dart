import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});
  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  bool _autoPhotos = true;
  bool _autoVideos = false;
  bool _autoFiles = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: cs.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Data & Storage', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Storage Usage
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(Icons.storage, color: cs.primary, size: 28),
              title: Text('Storage Usage', style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.12, backgroundColor: cs.onSurface.withOpacity(0.1), color: cs.primary, minHeight: 6)),
                const SizedBox(height: 6),
                Text('24 MB used', style: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 13)),
              ]),
              trailing: Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.3)),
              onTap: () {
                HapticFeedback.selectionClick();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: cs.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Storage Usage', style: TextStyle(color: cs.onSurface)),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      _storageRow('Photos', '12 MB', 0.5, cs),
                      const SizedBox(height: 12),
                      _storageRow('Videos', '6 MB', 0.25, cs),
                      const SizedBox(height: 12),
                      _storageRow('Files', '4 MB', 0.17, cs),
                      const SizedBox(height: 12),
                      _storageRow('Cache', '2 MB', 0.08, cs),
                      const SizedBox(height: 20),
                      Divider(color: cs.onSurface.withOpacity(0.1)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Total', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
                        Text('24 MB', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close', style: TextStyle(color: cs.primary))),
                    ],
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          _label('Auto-Download', cs),
          const SizedBox(height: 8),
          _card(cs, [
            _sw(Icons.photo_outlined, 'Photos', 'Download photos automatically', _autoPhotos, cs, (v) => setState(() => _autoPhotos = v)),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _sw(Icons.videocam_outlined, 'Videos', 'Download videos automatically', _autoVideos, cs, (v) => setState(() => _autoVideos = v)),
            Divider(height: 1, color: cs.onSurface.withOpacity(0.05), indent: 56),
            _sw(Icons.insert_drive_file_outlined, 'Files', 'Download files automatically', _autoFiles, cs, (v) => setState(() => _autoFiles = v)),
          ]),
          const SizedBox(height: 24),
          _card(cs, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.cleaning_services_outlined, color: Colors.orange.shade400, size: 24),
              title: Text('Clear Cache', style: TextStyle(color: Colors.orange.shade400, fontSize: 15, fontWeight: FontWeight.w500)),
              subtitle: Text('Free up storage space', style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
              onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(
                backgroundColor: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Clear Cache?', style: TextStyle(color: cs.onSurface)),
                content: Text('This will remove cached media. Original files remain on server.', style: TextStyle(color: cs.onSurface.withOpacity(0.7))),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: cs.onSurface.withOpacity(0.5)))),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Clear', style: TextStyle(color: Colors.orange.shade400, fontWeight: FontWeight.w600))),
                ],
              )),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _label(String t, ColorScheme cs) => Padding(padding: const EdgeInsets.only(left: 4), child: Text(t, style: TextStyle(color: cs.primary, fontSize: 14, fontWeight: FontWeight.w600)));
  Widget _card(ColorScheme cs, List<Widget> ch) => Container(decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)), child: Column(children: ch));
  Widget _sw(IconData icon, String title, String sub, bool val, ColorScheme cs, Function(bool) onChanged) => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    secondary: Icon(icon, color: cs.onSurface.withOpacity(0.7), size: 24),
    title: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
    subtitle: Text(sub, style: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 12)),
    value: val, activeColor: cs.primary, onChanged: onChanged,
  );

  Widget _storageRow(String label, String size, double progress, ColorScheme cs) {
    return Row(children: [
      Expanded(flex: 2, child: Text(label, style: TextStyle(color: cs.onSurface, fontSize: 14))),
      Expanded(flex: 3, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: cs.onSurface.withOpacity(0.1), color: cs.primary, minHeight: 6))),
      const SizedBox(width: 12),
      Text(size, style: TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13)),
    ]);
  }
}

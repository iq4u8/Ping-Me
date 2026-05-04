import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomMediaPickerBottomSheet extends StatefulWidget {
  final bool showOnlyGallery;
  const CustomMediaPickerBottomSheet({super.key, this.showOnlyGallery = false});

  @override
  State<CustomMediaPickerBottomSheet> createState() => _CustomMediaPickerBottomSheetState();
}

class _CustomMediaPickerBottomSheetState extends State<CustomMediaPickerBottomSheet> {
  List<AssetEntity> _assets = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _selectedTabIndex = 0; // 0: Gallery, 1: File, 2: Location, 3: Contact, 4: Music
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _requestPermissionAndLoadPhotos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadPhotos();
      }
    }
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      _loadPhotos();
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> _loadPhotos() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common, // images and videos
      onlyAll: true,
    );

    if (albums.isNotEmpty) {
      final List<AssetEntity> assets = await albums[0].getAssetListPaged(
        page: _currentPage,
        size: 60, // load 60 at a time
      );

      setState(() {
        _assets.addAll(assets);
        _currentPage++;
        _isLoading = false;
        if (assets.length < 60) {
          _hasMore = false;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Widget _buildGalleryTab(ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: _assets.isEmpty
              ? (_isLoading ? const Center(child: CircularProgressIndicator()) : Center(child: Text("No media found", style: TextStyle(color: colorScheme.onSurface))))
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, asset); // return selected asset
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AssetThumbnail(asset: asset),
                          if (asset.type == AssetType.video)
                            const Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(Icons.videocam, color: Colors.white, size: 20),
                            ),
                          // Add selection circle
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title, ColorScheme colorScheme) {
    return Center(child: Text(title, style: TextStyle(color: colorScheme.onSurface)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget content;
    if (_selectedTabIndex == 0) {
      content = _buildGalleryTab(colorScheme);
    } else if (_selectedTabIndex == 1) {
      content = _buildPlaceholderTab("File Picker", colorScheme);
    } else if (_selectedTabIndex == 2) {
      content = _buildPlaceholderTab("Location", colorScheme);
    } else if (_selectedTabIndex == 3) {
      content = _buildPlaceholderTab("Contact", colorScheme);
    } else {
      content = _buildPlaceholderTab("Music", colorScheme);
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Expanded(child: content),

          // Bottom Nav Bar
          if (!widget.showOnlyGallery)
            Container(
              padding: const EdgeInsets.only(top: 12, bottom: 24, left: 10, right: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.onSurface.withOpacity(0.05))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.photo_outlined, "Gallery", colorScheme),
                  _navItem(1, Icons.insert_drive_file_outlined, "File", colorScheme),
                  _navItem(2, Icons.location_on_outlined, "Location", colorScheme),
                  _navItem(3, Icons.person_outline, "Contact", colorScheme),
                  _navItem(4, Icons.music_note_outlined, "Music", colorScheme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, ColorScheme colorScheme) {
    final isSelected = _selectedTabIndex == index;
    final color = isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  const AssetThumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        return Container(color: Colors.grey[800]);
      },
    );
  }
}

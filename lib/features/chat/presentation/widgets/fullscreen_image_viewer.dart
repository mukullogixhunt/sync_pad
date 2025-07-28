import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler
import 'package:saver_gallery/saver_gallery.dart';

class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag; // For a smooth transition animation

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    // 1. Request Permission using permission_handler
    var status = await Permission.photos.request();

    if (!status.isGranted) {
      // On Android 13+, if the user denies once, they won't be prompted again.
      // We can guide them to settings.
      if (await Permission.photos.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission denied. Please enable it in app settings.',
              ),
            ),
          );
          openAppSettings();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to save images.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // --- THIS IS THE KEY CHANGE ---
      // We use the same cache manager that CachedNetworkImage uses by default.
      final File cachedImageFile = await DefaultCacheManager().getSingleFile(
        widget.imageUrl,
      );
      final Uint8List imageBytes = await cachedImageFile.readAsBytes();

      //  Save the bytes from the cached file to the gallery.
      final SaveResult result = await SaverGallery.saveImage(
        imageBytes,
        fileName: "sync_pad_${DateTime.now().millisecondsSinceEpoch}.jpg",
        skipIfExists: false,
        androidRelativePath: "Pictures/SyncPad",
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to SyncPad album!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(
            'Failed to save image. Error: ${result.errorMessage}',
          );
        }
      }
    } catch (e) {
      log("Image Download error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isDownloading)
            const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Save to Gallery',
              onPressed: _downloadImage,
            ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: widget.heroTag,
          child: InteractiveViewer(
            // Allows pinch-to-zoom and panning
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder:
                  (context, url) =>
                      const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

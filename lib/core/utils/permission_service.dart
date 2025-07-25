import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // This private helper remains the same, it's already robust.
  Future<bool> _requestPermission(
      Permission permission,
      BuildContext context,
      String featureName,
      ) async {
    final status = await permission.request();

    if (status.isGranted) {
      return true;
    }

    // If permission is permanently denied, show a dialog to guide the user to settings.
    if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, featureName);
      return false;
    }

    // For other cases like .isDenied, we simply return false.
    return false;
  }

  // Camera permission request is universal and doesn't need changes.
  Future<bool> requestCameraPermission(BuildContext context) async {
    return await _requestPermission(Permission.camera, context, 'Camera');
  }

  // --- THIS IS THE CORRECTED AND MODERN WAY TO REQUEST PHOTO/STORAGE PERMISSION ---
  Future<bool> requestPhotosPermission(BuildContext context) async {
    // For iOS, the permission is straightforward.
    if (Platform.isIOS) {
      return await _requestPermission(Permission.photos, context, 'Photos');
    }

    // For Android, we handle different SDK versions.
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // On Android 13 (SDK 33) and above, we request granular media permissions.
      if (androidInfo.version.sdkInt >= 33) {
        // Requesting photos and videos separately.
        // The permission_handler will show a single system dialog for both.
        final photoStatus = await _requestPermission(Permission.photos, context, 'Photos');
        // You could also request Permission.videos here if needed.
        return photoStatus;
      }
      // On Android versions below 13, Permission.storage is the correct one to request.
      else {
        return await _requestPermission(Permission.storage, context, 'Storage');
      }
    }

    // Fallback for other platforms (e.g., desktop) where it might not be applicable.
    return true;
  }

  // This helper function to show the settings dialog is perfect.
  void _showSettingsDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('$featureName Permission'),
        content: Text(
          'To use this feature, please grant the $featureName permission in your app settings.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
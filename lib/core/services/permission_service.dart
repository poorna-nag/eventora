import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const String _requestedKey = 'permissions_requested_';

  static Future<bool> shouldShowRequest(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('$_requestedKey$userId') ?? false);
  }

  static Future<void> markAsRequested(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_requestedKey$userId', true);
  }

  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    return await [
      Permission.location,
      Permission.camera,
      Permission.photos,
    ].request();
  }

  static Future<bool> hasAllPermissions() async {
    final location = await Permission.location.isGranted;
    final camera = await Permission.camera.isGranted;
    final photos = await Permission.photos.isGranted;
    return location && camera && photos;
  }
}

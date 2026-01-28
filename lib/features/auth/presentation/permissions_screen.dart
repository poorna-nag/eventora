import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/services/permission_service.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionsScreen extends StatefulWidget {
  final String userId;
  const PermissionsScreen({super.key, required this.userId});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isRequesting = false;

  Future<void> _handlePermissions() async {
    setState(() => _isRequesting = true);

    // Request all permissions
    await PermissionService.requestAllPermissions();

    // Mark as requested so it won't show again
    await PermissionService.markAsRequested(widget.userId);

    if (mounted) {
      NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.security_outlined,
                        size: 60,
                        color: AppColors.iconColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.permissionsTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.permissionsSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildPermissionTile(
                        Icons.location_on_outlined,
                        AppStrings.locationPermission,
                        AppStrings.locationPermissionDesc,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        Icons.camera_alt_outlined,
                        AppStrings.cameraPermission,
                        AppStrings.cameraPermissionDesc,
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionTile(
                        Icons.photo_library_outlined,
                        AppStrings.storagePermission,
                        AppStrings.storagePermissionDesc,
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: AppStrings.allowAll,
                        onPressed: _handlePermissions,
                        isLoading: _isRequesting,
                        backgroundColor: AppColors.iconColor,
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

  Widget _buildPermissionTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHeadline,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

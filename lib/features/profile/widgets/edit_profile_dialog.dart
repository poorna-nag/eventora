import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/utils/validators.dart';
import 'package:eventora/features/auth/data/user_model.dart';
import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _workplaceController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  List<String> _selectedInterests = [];
  bool _isLoading = false;

  final List<String> _availableInterests = [
    'Music',
    'Sports',
    'Tech',
    'Food',
    'Art',
    'Business',
    'Party',
    'DJ',
    'Dance',
    'Games',
    'Live',
    'Travel',
    'Photography',
    'Fitness',
    'Reading',
    'Movies',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _workplaceController = TextEditingController(
      text: widget.user.workplace ?? '',
    );
    _instagramController = TextEditingController(
      text: widget.user.instagram ?? '',
    );
    _twitterController = TextEditingController(text: widget.user.twitter ?? '');
    _selectedInterests = List.from(widget.user.interests ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _workplaceController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
            'name': _nameController.text.trim(),
            'bio': _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            'workplace': _workplaceController.text.trim().isEmpty
                ? null
                : _workplaceController.text.trim(),
            'instagram': _instagramController.text.trim().isEmpty
                ? null
                : _instagramController.text.trim(),
            'twitter': _twitterController.text.trim().isEmpty
                ? null
                : _twitterController.text.trim(),
            'interests': _selectedInterests.isEmpty ? null : _selectedInterests,
          });

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.profileUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.profileUpdateFailed}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: AppStrings.name,
                        icon: Icons.person,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _bioController,
                        label: AppStrings.bio,
                        icon: Icons.info_outline,
                        maxLines: 3,
                        hint: AppStrings.bioHint,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _workplaceController,
                        label: AppStrings.workplace,
                        icon: Icons.work_outline,
                        hint: AppStrings.workplaceHint,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _instagramController,
                        label: 'Instagram',
                        icon: Icons.camera_alt,
                        hint: AppStrings.socialHint,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _twitterController,
                        label: 'Twitter',
                        icon: Icons.alternate_email,
                        hint: AppStrings.socialHint,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        AppStrings.interests,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInterestsWrap(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit, color: AppColors.iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            AppStrings.editProfile,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildInterestsWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected
                  ? _selectedInterests.remove(interest)
                  : _selectedInterests.add(interest);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.iconColor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                Text(
                  interest,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.iconColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    AppStrings.save,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.iconColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.iconColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_app/database/database_helper.dart';

import '../controllers/image_picker.dart';
import '../utils/snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Controller for name and email text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fetch profile data from SQLite database
  void _loadProfileData() async {
    final profile = await DatabaseHelper().getProfile();
    if (profile != null) {
      _nameController.text = profile['name'];
      _emailController.text = profile['email'];
      _profilePicture = profile['profile_picture'];
    }
    setState(() {});
  }

  // Save profile data to SQLite database
  void _saveProfile() async {
    final updatedProfile = {
      'name': _nameController.text,
      'email': _emailController.text,
      'profile_picture': _profilePicture ?? '',
    };
    await DatabaseHelper().insertProfile(updatedProfile);
    showSnackBar(context, 'Profile updated successfully');
  }

  final ImagePickerService _imagePickerService = ImagePickerService();

  // Pick a profile picture
  Future<void> _pickImage() async {
    final pickedImagePath =
        await _imagePickerService.pickProfilePicture(context);

    if (pickedImagePath != null) {
      setState(() {
        _profilePicture = pickedImagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display profile picture
            GestureDetector(
              onTap: _pickImage, // Let the user change the profile picture
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null
                    ? FileImage(File(_profilePicture!))
                    : const AssetImage('assets/launcher_icon.jpg')
                        as ImageProvider, // Default image
                child: _profilePicture == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            // Display name input field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            // Display email input field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            // Save profile button
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

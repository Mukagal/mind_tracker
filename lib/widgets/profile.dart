import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mob_edu/config.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class ProfileAvatar extends StatefulWidget {
  final int? userID;

  const ProfileAvatar({super.key, required this.userID});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ImagePicker picker = ImagePicker();
  XFile? _image;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (widget.userID == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/${widget.userID}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _profileImageUrl = data['profile_image'] != null
              ? '$baseUrl${data['profile_image']}'
              : null;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading profile image: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request camera permission if taking photo
    if (source == ImageSource.camera) {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _image = image;
      });

      await _uploadImage(image);
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _uploadImage(XFile image) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile/${widget.userID}');
    final request = http.MultipartRequest('POST', uri);

    try {
      if (!kIsWeb) {
        request.files.add(
          await http.MultipartFile.fromPath('profile', image.path),
        );
      } else {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('profile', bytes, filename: image.name),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Upload success");
        await _loadProfileImage();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } else {
        print("❌ Upload failed: ${response.statusCode}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      }
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(),
      );
    }

    ImageProvider? avatarProvider;

    if (_image != null) {
      if (kIsWeb) {
        avatarProvider = NetworkImage(_image!.path);
      } else {
        avatarProvider = FileImage(File(_image!.path));
      }
    } else if (_profileImageUrl != null) {
      avatarProvider = NetworkImage(_profileImageUrl!);
    }

    return GestureDetector(
      onTap: _showOptions,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white.withOpacity(0.6),
        backgroundImage: avatarProvider,
        child: avatarProvider == null
            ? const Icon(Icons.person, size: 60, color: Colors.black54)
            : null,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/user_provider.dart';

class UploadFloorPlanScreen extends ConsumerStatefulWidget {
  const UploadFloorPlanScreen({super.key});

  @override
  ConsumerState<UploadFloorPlanScreen> createState() =>
      _UploadFloorPlanScreenState();
}

class _UploadFloorPlanScreenState extends ConsumerState<UploadFloorPlanScreen> {
  final _versionController = TextEditingController();
  final _apiService = ApiService();
  File? _image;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _upload() async {
    if (_image == null || _versionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select image and enter version')),
      );
      return;
    }

    final user = ref.read(userProvider);
    if (user.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      String fileName = _image!.path.split('/').last;
      FormData formData = FormData.fromMap({
        'version': _versionController.text,
        'created_by': user.id,
        'image': await MultipartFile.fromFile(_image!.path, filename: fileName),
        'data_json': '{}',
      });

      final response = await _apiService.post(
        '/floor-plans/upload',
        data: formData,
        offlinePayload: {
          'type': 'upload_floor_plan',
          'version': _versionController.text,
          'created_by': user.id,
          'image_path': _image!.path,
        },
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload successful')));
          Navigator.pop(context);
        }
      } else if (response.statusCode == 409) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Conflict Detected'),
                  content: Text(
                    'A newer version (${response.data['latestVersion']}) exists. Your version: ${response.data['yourVersion']}.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${response.data['message']}'),
            ),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Floor Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _versionController,
              decoration: const InputDecoration(labelText: 'Version Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _upload,
                  child: const Text('Upload'),
                ),
          ],
        ),
      ),
    );
  }
}

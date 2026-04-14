import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  File? _selectedImage;
  String _status = 'Choose an image from the gallery.';

  Future<void> _pickFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (!mounted) {
      return;
    }

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      setState(() {
        _selectedImage = null;
        _status = 'No image selected.';
      });
      return;
    }

    setState(() {
      _selectedImage = File(result.files.single.path!);
      _status = 'Image loaded from gallery.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery Picker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 300)
              else
                const Text('No image selected'),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFromGallery,
                child: const Text('Pick from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

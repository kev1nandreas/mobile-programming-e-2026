import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  PlatformFile? _selectedFile;
  String _status = 'Choose a file from device storage.';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (!mounted) {
      return;
    }

    if (result == null || result.files.isEmpty) {
      setState(() {
        _selectedFile = null;
        _status = 'No file was selected.';
      });
      return;
    }

    setState(() {
      _selectedFile = result.files.single;
      _status = 'File selected successfully.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Access')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.folder, size: 72),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null) ...[
                Text('Name: ${_selectedFile!.name}'),
                const SizedBox(height: 8),
                Text('Size: ${_selectedFile!.size} bytes'),
                if (_selectedFile!.path != null) ...[
                  const SizedBox(height: 8),
                  Text('Path: ${_selectedFile!.path}'),
                ],
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}

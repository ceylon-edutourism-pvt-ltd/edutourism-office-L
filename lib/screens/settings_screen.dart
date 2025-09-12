import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;

  const SettingsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings(
      logoPath: widget.settings.logoPath,
      signaturePath: widget.settings.signaturePath,  // Added signature path
      outputDirectory: widget.settings.outputDirectory,
      bulkModeEnabled: widget.settings.bulkModeEnabled,
      logoPositionX: widget.settings.logoPositionX,
      logoPositionY: widget.settings.logoPositionY,
      logoWidth: widget.settings.logoWidth,
      logoHeight: widget.settings.logoHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_settings),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // App info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'PDF Generation',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Letters are generated directly as PDF files using Flutter\'s built-in PDF package. No external software required!',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Bulk mode toggle
            SwitchListTile(
              title: const Text('Bulk Mode'),
              subtitle: const Text('Generate multiple letters at once'),
              value: _settings.bulkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _settings.bulkModeEnabled = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Logo settings
            const Text(
              'Logo Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Logo File'),
              subtitle: Text(_settings.logoPath.isEmpty 
                  ? 'Using default logo' 
                  : _settings.logoPath.split('/').last),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: _selectLogoFile,
              ),
            ),

            const SizedBox(height: 16),

            // Signature settings
            const Text(
              'Signature Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text('Signature File'),
              subtitle: Text(_settings.signaturePath.isEmpty 
                  ? 'Using default signature' 
                  : _settings.signaturePath.split('/').last),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: _selectSignatureFile,
              ),
            ),

            const SizedBox(height: 16),

            // Output settings
            const Text(
              'Output Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Output Directory'),
              subtitle: Text(_settings.outputDirectory.isEmpty 
                  ? 'Documents folder (default)' 
                  : _settings.outputDirectory),
              trailing: IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: _selectOutputDirectory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLogoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _settings.logoPath = result.files.single.path!;
      });
    }
  }

  Future<void> _selectSignatureFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _settings.signaturePath = result.files.single.path!;
      });
    }
  }

  Future<void> _selectOutputDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _settings.outputDirectory = selectedDirectory;
      });
    }
  }
}
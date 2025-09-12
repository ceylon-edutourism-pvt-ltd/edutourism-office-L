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
      outputDirectory: widget.settings.outputDirectory,
      bulkModeEnabled: widget.settings.bulkModeEnabled,
      logoPositionX: widget.settings.logoPositionX,
      logoPositionY: widget.settings.logoPositionY,
      logoWidth: widget.settings.logoWidth,
      logoHeight: widget.settings.logoHeight,
      libreOfficeCommand: widget.settings.libreOfficeCommand,
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
            // Template info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Template Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Default Templates:'),
                    const Text('• Malaysia Study Tour Invitation.docx', 
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                    const Text('• Passport Request Letter.docx', 
                        style: TextStyle(fontSize: 12, color: Colors.green)),
                    const SizedBox(height: 8),
                    const Text(
                      'Place your DOCX templates in the assets folder with these exact names.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            
            // App Settings
            const Text(
              'Application Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Bulk mode toggle
            SwitchListTile(
              title: const Text('Bulk Mode'),
              subtitle: const Text('Enable bulk letter generation with multiple names'),
              value: _settings.bulkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _settings.bulkModeEnabled = value;
                });
              },
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Logo Settings
            const Text(
              'Logo Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _settings.logoPath.isNotEmpty && File(_settings.logoPath).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(_settings.logoPath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.business, color: Colors.blue);
                        },
                      ),
              ),
              title: const Text('Logo File'),
              subtitle: Text(_settings.logoPath.isEmpty 
                  ? 'Using default: assets/logo.png' 
                  : _settings.logoPath.split('/').last),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_settings.logoPath.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _settings.logoPath = '';
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _selectLogoFile,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Output Settings
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

            const SizedBox(height: 16),
            
            // LibreOffice Settings
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
                          'PDF Conversion Settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All letters are automatically converted to PDF. LibreOffice is required for conversion.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'LibreOffice Command',
                        helperText: 'Command to run LibreOffice (e.g., "soffice" or full path)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.terminal),
                      ),
                      initialValue: _settings.libreOfficeCommand,
                      onChanged: (value) {
                        _settings.libreOfficeCommand = value;
                      },
                    ),
                  ],
                ),
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

  Future<void> _selectOutputDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _settings.outputDirectory = selectedDirectory;
      });
    }
  }
}

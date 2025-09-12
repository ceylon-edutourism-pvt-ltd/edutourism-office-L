import 'package:flutter/material.dart';
import 'dart:io';
import '../models/letter_data.dart';
import '../models/settings.dart';
import '../services/docx_service.dart';
import '../widgets/letter_form.dart';
import '../widgets/bulk_mode_widget.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSettings settings = AppSettings();
  LetterData letterData = LetterData();
  List<BulkLetterData> bulkLetters = [];
  bool isGenerating = false;
  List<String> availableTags = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableTags();
  }

  Future<void> _loadAvailableTags() async {
    final service = DocxService(settings);
    final tags = await service.extractPlaceholdersFromTemplate(LetterType.malaysiaStudyTourInvitation);
    setState(() {
      availableTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letter Generator - Final Version'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTemplateInfo,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Logo section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildLogo(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'OFFICE L',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Malaysia Study Tour • Passport Request',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: settings.bulkModeEnabled
                  ? BulkModeWidget(
                      bulkLetters: bulkLetters,
                      onBulkLettersChanged: (letters) {
                        setState(() {
                          bulkLetters = letters;
                        });
                      },
                      letterData: letterData,
                      onLetterDataChanged: (data) {
                        setState(() {
                          letterData = data;
                        });
                      },
                      onGenerate: _generateBulkLetters,
                      isGenerating: isGenerating,
                    )
                  : LetterForm(
                      letterData: letterData,
                      onDataChanged: (data) {
                        setState(() {
                          letterData = data;
                        });
                      },
                      onGenerate: _generateLetters,
                      isGenerating: isGenerating,
                    ),
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Powered by Lindo Solutions',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    if (settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync()) {
      return Image.file(
        File(settings.logoPath),
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultLogo();
        },
      );
    }
    
    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return Image.asset(
      'assets/logo.png',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.business, 
          size: 50, 
          color: Colors.blue
        );
      },
    );
  }

  void _showTemplateInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Template Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Templates:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('• Malaysia Study Tour Invitation'),
            const Text('• Passport Request Letter'),
            const SizedBox(height: 15),
            const Text(
              'Name Format:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'Full name "ethugala arachchi tharusha gimsara"\nwill become "E.A.T.GIMSARA"',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 15),
            const Text(
              'Available Placeholders:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            ...DocxService(settings).getStandardPlaceholders().map(
              (tag) => Text('• {$tag}', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openSettings() async {
    final newSettings = await Navigator.of(context).push<AppSettings>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(settings: settings),
      ),
    );
    
    if (newSettings != null) {
      setState(() {
        settings = newSettings;
      });
      await _loadAvailableTags();
    }
  }

  Future<void> _generateLetters() async {
    if (letterData.name.isEmpty || letterData.identificationNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (letterData.selectedLetterTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one letter type')),
      );
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      final service = DocxService(settings);
      int successCount = 0;
      int errorCount = 0;
      
      for (final letterType in letterData.selectedLetterTypes) {
        try {
          final docxBytes = await service.generateDocxFromTemplate(letterData, letterType);
          if (docxBytes != null) {
            final fileName = service.generateFileName(letterData, letterType);
            final pdfPath = await service.saveAndConvertToPdf(fileName, docxBytes);
            
            await service.openFile(pdfPath);
            successCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          print('Error generating ${letterType.name}: $e');
          errorCount++;
        }
      }

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generated $successCount PDF letter(s) successfully!')),
        );
      }
      
      if (errorCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorCount letter(s) failed to generate'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating letters: $e')),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  Future<void> _generateBulkLetters() async {
    if (bulkLetters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add names for bulk generation')),
      );
      return;
    }

    if (letterData.selectedLetterTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one letter type')),
      );
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      final service = DocxService(settings);
      int totalCount = 0;
      
      for (final letterType in letterData.selectedLetterTypes) {
        for (int i = 0; i < bulkLetters.length; i++) {
          final bulkItem = bulkLetters[i];
          
          final individualData = LetterData(
            name: bulkItem.name,
            identificationType: letterData.identificationType,
            identificationNumber: bulkItem.identificationNumber,
            selectedLetterTypes: {letterType},
            sponsorName: letterData.sponsorName,
            dependentName: letterData.dependentName,
            occupation: letterData.occupation,
            projectDetails: letterData.projectDetails,
            contractDetails: letterData.contractDetails,
          );
          
          final docxBytes = await service.generateDocxFromTemplate(individualData, letterType);
          if (docxBytes != null) {
            final fileName = '${service.generateFileName(individualData, letterType)}_${i + 1}';
            await service.saveAndConvertToPdf(fileName, docxBytes);
            totalCount++;
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated $totalCount PDF letter(s) successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating bulk letters: $e')),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }
}

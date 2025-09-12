import 'package:flutter/material.dart';
import 'dart:io';
import '../models/letter_data.dart';
import '../models/settings.dart';
import '../services/pdf_service.dart';  // Changed from docx_service
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letter Generator Edutourism'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
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

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Letter Generator Info'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Letters:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('• Malaysia Study Tour Invitation'),
            Text('• Passport Request Letter'),
            Text('• Employment Confirmation'),
            Text('• And more...'),
            SizedBox(height: 15),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('✓ Direct PDF generation'),
            Text('✓ Auto initials conversion'),
            Text('✓ No external software needed'),
            Text('✓ Professional formatting'),
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
      final service = PdfService(settings); // Fixed: using PdfService
      int successCount = 0;
      
      for (final letterType in letterData.selectedLetterTypes) {
        try {
          final pdfPath = await service.generateLetterPdf(letterData, letterType);
          await service.openFile(pdfPath);
          successCount++;
        } catch (e) {
          print('Error generating ${letterType.name}: $e');
        }
      }

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generated $successCount PDF letter(s) successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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

    setState(() {
      isGenerating = true;
    });

    try {
      final service = PdfService(settings); // Fixed: using PdfService
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
          
          await service.generateLetterPdf(individualData, letterType);
          totalCount++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generated $totalCount PDF letter(s)!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }
}

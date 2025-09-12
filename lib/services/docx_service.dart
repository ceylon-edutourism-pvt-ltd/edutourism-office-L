import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:libre_doc_converter/libre_doc_converter.dart';
import '../models/letter_data.dart';
import '../models/settings.dart';

class DocxService {
  final AppSettings settings;
  
  DocxService(this.settings);

  Future<Uint8List?> generateDocxFromTemplate(
    LetterData data, 
    LetterType letterType
  ) async {
    try {
      // Load template from assets based on letter type
      final templateBytes = await _loadTemplateFromAssets(letterType);
      if (templateBytes == null) {
        return await _generateFromDefaultTemplate(data, letterType);
      }
      
      return await _processTemplate(templateBytes, data);
    } catch (e) {
      print('Error generating DOCX: $e');
      return await _generateFromDefaultTemplate(data, letterType);
    }
  }

  Future<Uint8List?> _loadTemplateFromAssets(LetterType letterType) async {
    try {
      String assetPath;
      
      switch (letterType) {
        case LetterType.malaysiaStudyTourInvitation:
          assetPath = 'assets/Malaysia Study Tour Invitation.docx';
          break;
        case LetterType.passportRequestLetter:
          assetPath = 'assets/Passport Request Letter.docx';
          break;
        default:
          // For other letter types, use a default template or generate one
          return null;
      }
      
      final byteData = await rootBundle.load(assetPath);
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error loading template from assets: $e');
      return null;
    }
  }

  Future<Uint8List?> _generateFromDefaultTemplate(LetterData data, LetterType letterType) async {
    try {
      final content = _generateDefaultContent(data, letterType);
      final archive = Archive();
      
      archive.addFile(ArchiveFile('[Content_Types].xml', _contentTypes.length, 
          Uint8List.fromList(_contentTypes.codeUnits)));
      archive.addFile(ArchiveFile('_rels/.rels', _rels.length, 
          Uint8List.fromList(_rels.codeUnits)));
      archive.addFile(ArchiveFile('word/_rels/document.xml.rels', _docRels.length, 
          Uint8List.fromList(_docRels.codeUnits)));
      archive.addFile(ArchiveFile('word/document.xml', content.length, 
          Uint8List.fromList(content.codeUnits)));
      
      return Uint8List.fromList(ZipEncoder().encode(archive)!);
    } catch (e) {
      print('Error generating default template: $e');
      return null;
    }
  }

  String _generateDefaultContent(LetterData data, LetterType letterType) {
    final templateData = data.toTemplateData();
    String title = _getLetterTitle(letterType);
    String body = _getLetterBody(letterType, templateData);
    
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p>
      <w:pPr><w:jc w:val="center"/></w:pPr>
      <w:r><w:rPr><w:b/></w:rPr><w:t>$title</w:t></w:r>
    </w:p>
    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p><w:r><w:t>Date: ${templateData['current_date']}</w:t></w:r></w:p>
    <w:p><w:r><w:t></w:t></w:r></w:p>
    $body
    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p><w:r><w:t>Best regards,</w:t></w:r></w:p>
    <w:p><w:r><w:t>OFFICE L</w:t></w:r></w:p>
    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p>
      <w:pPr><w:jc w:val="center"/></w:pPr>
      <w:r><w:rPr><w:i/></w:rPr><w:t>Powered by Lindo Solutions</w:t></w:r>
    </w:p>
  </w:body>
</w:document>''';
  }

  String _getLetterTitle(LetterType letterType) {
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'MALAYSIA STUDY TOUR INVITATION';
      case LetterType.passportRequestLetter:
        return 'PASSPORT REQUEST LETTER';
      case LetterType.invitationLetter:
        return 'INVITATION LETTER';
      case LetterType.visaRequestLetter:
        return 'VISA REQUEST LETTER';
      case LetterType.leaveLetter:
        return 'LEAVE APPLICATION';
      case LetterType.sponsorshipLetter:
        return 'SPONSORSHIP LETTER';
      case LetterType.dependentLetter:
        return 'DEPENDENT LETTER';
      case LetterType.freelancerLetter:
        return 'FREELANCER CONFIRMATION';
      case LetterType.employmentConfirmationLetter:
        return 'EMPLOYMENT CONFIRMATION';
    }
  }

  String _getLetterBody(LetterType letterType, Map<String, String> data) {
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return '''<w:p><w:r><w:t>Dear ${data['name']},</w:t></w:r></w:p>
<w:p><w:r><w:t></w:t></w:r></w:p>
<w:p><w:r><w:t>We are pleased to invite you to participate in our Malaysia Study Tour program.</w:t></w:r></w:p>
<w:p><w:r><w:t>Name with Initials: ${data['name_with_initials']}</w:t></w:r></w:p>
<w:p><w:r><w:t>${data['identification_type']}: ${data['identification_number']}</w:t></w:r></w:p>
<w:p><w:r><w:t></w:t></w:r></w:p>
<w:p><w:r><w:t>This invitation is valid for the upcoming study tour to Malaysia.</w:t></w:r></w:p>''';
      
      case LetterType.passportRequestLetter:
        return '''<w:p><w:r><w:t>To Whom It May Concern,</w:t></w:r></w:p>
<w:p><w:r><w:t></w:t></w:r></w:p>
<w:p><w:r><w:t>This letter is to request passport services for ${data['name']}.</w:t></w:r></w:p>
<w:p><w:r><w:t>Name with Initials: ${data['name_with_initials']}</w:t></w:r></w:p>
<w:p><w:r><w:t>${data['identification_type']}: ${data['identification_number']}</w:t></w:r></w:p>''';
      
      default:
        return '''<w:p><w:r><w:t>Dear ${data['name']},</w:t></w:r></w:p>
<w:p><w:r><w:t></w:t></w:r></w:p>
<w:p><w:r><w:t>This letter is generated for ${data['name_with_initials']} (${data['identification_type']}: ${data['identification_number']}).</w:t></w:r></w:p>''';
    }
  }

  Future<Uint8List> _processTemplate(Uint8List templateBytes, LetterData data) async {
    try {
      final archive = ZipDecoder().decodeBytes(templateBytes);
      final newArchive = Archive();
      final replacements = data.toTemplateData();

      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          String content = String.fromCharCodes(file.content);
          
          replacements.forEach((key, value) {
            content = content.replaceAll('{$key}', value);
          });
          
          newArchive.addFile(ArchiveFile(
            file.name,
            content.length,
            Uint8List.fromList(content.codeUnits),
          ));
        } else {
          newArchive.addFile(ArchiveFile(
            file.name,
            file.size,
            file.content,
          ));
        }
      }

      return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
    } catch (e) {
      print('Error processing template: $e');
      return templateBytes;
    }
  }

  // Generate filename based on letter type and name with initials
  String generateFileName(LetterData data, LetterType letterType) {
    final nameWithInitials = data.nameWithInitials;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'Malaysia Study Tour Invitation $nameWithInitials';
      case LetterType.passportRequestLetter:
        return 'Passport Request Letter $nameWithInitials';
      default:
        return '${_getLetterTitle(letterType)} $nameWithInitials $timestamp';
    }
  }

  // Save DOCX and convert to PDF
  Future<String> saveAndConvertToPdf(String fileName, Uint8List docxBytes) async {
    final directory = settings.outputDirectory.isNotEmpty 
        ? Directory(settings.outputDirectory)
        : await getApplicationDocumentsDirectory();
    
    // Save DOCX temporarily
    final docxPath = "${directory.path}/$fileName.docx";
    final docxFile = File(docxPath);
    await docxFile.writeAsBytes(docxBytes);
    
    try {
      // Convert to PDF using LibreOffice converter
      final converter = LibreDocConverter(inputFile: docxFile);
      final pdfFile = await converter.toPdf();
      
      // Delete temporary DOCX file
      await docxFile.delete();
      
      return pdfFile.path;
    } catch (e) {
      print('Error converting to PDF: $e');
      // Fallback: try LibreOffice command line
      return await _convertUsingLibreOfficeCommand(docxPath, fileName, directory);
    }
  }

  Future<String> _convertUsingLibreOfficeCommand(String docxPath, String fileName, Directory directory) async {
    try {
      final pdfPath = "${directory.path}/$fileName.pdf";
      
      final result = await Process.run(
        settings.libreOfficeCommand,
        [
          '--headless',
          '--convert-to',
          'pdf',
          '--outdir',
          directory.path,
          docxPath,
        ],
        runInShell: true,
      );
      
      if (result.exitCode == 0 && File(pdfPath).existsSync()) {
        await File(docxPath).delete(); // Delete DOCX
        return pdfPath;
      } else {
        print('LibreOffice conversion failed: ${result.stderr}');
        return docxPath; // Return DOCX if conversion fails
      }
    } catch (e) {
      print('Error with LibreOffice command: $e');
      return docxPath;
    }
  }

  // Open file
  Future<void> openFile(String filePath) async {
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', '""', filePath], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.start('xdg-open', [filePath], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [filePath], runInShell: true);
    }
  }

  // Extract placeholders from assets template
  Future<List<String>> extractPlaceholdersFromTemplate(LetterType letterType) async {
    try {
      final templateBytes = await _loadTemplateFromAssets(letterType);
      if (templateBytes == null) return [];
      
      final archive = ZipDecoder().decodeBytes(templateBytes);
      
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          final xmlContent = String.fromCharCodes(file.content);
          final regex = RegExp(r'\{([^}]+)\}');
          final matches = regex.allMatches(xmlContent);
          
          return matches.map((match) => match.group(1)!).toSet().toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error extracting placeholders: $e');
      return [];
    }
  }

  List<String> getStandardPlaceholders() {
    return [
      'name',
      'name_with_initials',
      'identification_type',
      'identification_number',
      'sponsor_name',
      'dependent_name',
      'occupation',
      'project_details',
      'contract_details',
      'current_date',
      'current_year',
      'current_month',
      'current_day',
    ];
  }

  // DOCX structure constants
  static const String _contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';

  static const String _rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  static const String _docRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>''';
}

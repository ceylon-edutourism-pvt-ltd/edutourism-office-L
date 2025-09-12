import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/letter_data.dart';
import '../models/settings.dart';

class PdfService {
  final AppSettings settings;
  
  PdfService(this.settings);

  Future<String> generateLetterPdf(LetterData data, LetterType letterType) async {
    final pdf = pw.Document();
    
    // Load logo
    pw.ImageProvider? logoImage;
    try {
      if (settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync()) {
        final logoBytes = await File(settings.logoPath).readAsBytes();
        logoImage = pw.MemoryImage(logoBytes);
      } else {
        final logoBytes = (await rootBundle.load("assets/logo.png")).buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      print('Error loading logo: $e');
    }

    // Add page with content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          if (logoImage != null)
            pw.Center(
              child: pw.Image(logoImage, width: 100, height: 100),
            ),
          pw.SizedBox(height: 20),
          
          pw.Center(
            child: pw.Text(
              'OFFICE L',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          
          // Letter content based on type
          ...buildLetterContent(data, letterType),
          
          pw.Spacer(),
          pw.Center(
            child: pw.Text(
              'Powered by Lindo Solutions',
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey,
              ),
            ),
          ),
        ],
      ),
    );

    // Save PDF
    final fileName = generateFileName(data, letterType);
    final directory = settings.outputDirectory.isNotEmpty 
        ? Directory(settings.outputDirectory)
        : await getApplicationDocumentsDirectory();
    
    final filePath = "${directory.path}/$fileName.pdf";
    final file = File(filePath);
    
    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes);
    
    return filePath;
  }

  List<pw.Widget> buildLetterContent(LetterData data, LetterType letterType) {
    final templateData = data.toTemplateData();
    
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return [
          pw.Center(
            child: pw.Text(
              'MALAYSIA STUDY TOUR INVITATION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Date: ${templateData['current_date']}'),
          pw.SizedBox(height: 20),
          pw.Text('Dear ${templateData['name']},'),
          pw.SizedBox(height: 15),
          pw.Text(
            'We are pleased to invite you to participate in our Malaysia Study Tour program.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 15),
          pw.Text('Name with Initials: ${templateData['name_with_initials']}'),
          pw.Text('${templateData['identification_type']}: ${templateData['identification_number']}'),
          pw.SizedBox(height: 20),
          pw.Text(
            'This invitation is valid for the upcoming study tour to Malaysia. Please ensure all travel documents are prepared accordingly.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 30),
          pw.Text('Best regards,'),
          pw.SizedBox(height: 15),
          pw.Text(
            'OFFICE L',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Study Tour Coordination Team'),
        ];
        
      case LetterType.passportRequestLetter:
        return [
          pw.Center(
            child: pw.Text(
              'PASSPORT REQUEST LETTER',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Date: ${templateData['current_date']}'),
          pw.SizedBox(height: 20),
          pw.Text('To Whom It May Concern,'),
          pw.SizedBox(height: 15),
          pw.Text(
            'This letter is to request passport services for the following individual:',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 15),
          pw.Text('Full Name: ${templateData['name']}'),
          pw.Text('Name with Initials: ${templateData['name_with_initials']}'),
          pw.Text('${templateData['identification_type']}: ${templateData['identification_number']}'),
          pw.SizedBox(height: 20),
          pw.Text(
            'This request is made for official travel purposes related to educational programs.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 30),
          pw.Text('Thank you for your assistance.'),
          pw.SizedBox(height: 15),
          pw.Text('Sincerely,'),
          pw.SizedBox(height: 15),
          pw.Text(
            'OFFICE L',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('Administrative Department'),
        ];

      case LetterType.invitationLetter:
        return [
          pw.Center(
            child: pw.Text(
              'INVITATION LETTER',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Date: ${templateData['current_date']}'),
          pw.SizedBox(height: 20),
          pw.Text('Dear ${templateData['name']},'),
          pw.SizedBox(height: 15),
          pw.Text(
            'We are pleased to invite you to our upcoming event.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 15),
          pw.Text('Name with Initials: ${templateData['name_with_initials']}'),
          pw.Text('${templateData['identification_type']}: ${templateData['identification_number']}'),
          pw.SizedBox(height: 20),
          pw.Text('We look forward to your presence.'),
          pw.SizedBox(height: 30),
          pw.Text('Best regards,'),
          pw.SizedBox(height: 15),
          pw.Text('OFFICE L Team'),
        ];

      case LetterType.employmentConfirmationLetter:
        return [
          pw.Center(
            child: pw.Text(
              'EMPLOYMENT CONFIRMATION LETTER',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Date: ${templateData['current_date']}'),
          pw.SizedBox(height: 20),
          pw.Text('To Whom It May Concern,'),
          pw.SizedBox(height: 15),
          pw.Text(
            'This letter confirms that ${templateData['name_with_initials']} (${templateData['identification_type']}: ${templateData['identification_number']}) is employed with our organization.',
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 15),
          if (templateData['occupation']?.isNotEmpty == true)
            pw.Text('Position: ${templateData['occupation']}'),
          if (templateData['contract_details']?.isNotEmpty == true)
            pw.Text('Contract Details: ${templateData['contract_details']}'),
          pw.SizedBox(height: 20),
          pw.Text('This letter is issued for official purposes.'),
          pw.SizedBox(height: 30),
          pw.Text('Sincerely,'),
          pw.SizedBox(height: 15),
          pw.Text('HR Department'),
          pw.Text('OFFICE L'),
        ];

      // Add other letter types similarly...
      default:
        return [
          pw.Center(
            child: pw.Text(
              _getLetterTitle(letterType),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 30),
          pw.Text('Date: ${templateData['current_date']}'),
          pw.SizedBox(height: 20),
          pw.Text('Dear ${templateData['name']},'),
          pw.SizedBox(height: 15),
          pw.Text('Name with Initials: ${templateData['name_with_initials']}'),
          pw.Text('${templateData['identification_type']}: ${templateData['identification_number']}'),
          pw.SizedBox(height: 20),
          pw.Text('This letter is generated for official purposes.'),
          pw.SizedBox(height: 30),
          pw.Text('Best regards,'),
          pw.SizedBox(height: 15),
          pw.Text('OFFICE L'),
        ];
    }
  }

  String generateFileName(LetterData data, LetterType letterType) {
    final nameWithInitials = data.nameWithInitials;
    
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'Malaysia Study Tour Invitation $nameWithInitials';
      case LetterType.passportRequestLetter:
        return 'Passport Request Letter $nameWithInitials';
      default:
        return '${_getLetterTitle(letterType)} $nameWithInitials';
    }
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

  Future<void> openFile(String filePath) async {
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', '""', filePath], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.start('xdg-open', [filePath], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [filePath], runInShell: true);
    }
  }
}

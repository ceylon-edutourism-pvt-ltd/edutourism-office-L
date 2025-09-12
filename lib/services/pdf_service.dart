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
    // Load Unicode-supporting fonts
    final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    
    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    // Create document
    final pdf = pw.Document();
    
    // Load logo
    pw.ImageProvider? logoImage;
    try {
      if (settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync()) {
        final logoBytes = await File(settings.logoPath).readAsBytes();
        logoImage = pw.MemoryImage(logoBytes);
      } else {
        final logoBytes = (await rootBundle.load("assets/Picture1.jpg")).buffer.asUint8List();
        logoImage = pw.MemoryImage(logoBytes);
      }
    } catch (e) {
      print('Logo loading failed: $e');
    }

    // Load signature
    pw.ImageProvider? signatureImage;
    try {
      if (settings.signaturePath.isNotEmpty && File(settings.signaturePath).existsSync()) {
        final signatureBytes = await File(settings.signaturePath).readAsBytes();
        signatureImage = pw.MemoryImage(signatureBytes);
      } else {
        final signatureBytes = (await rootBundle.load("assets/Picture4.png")).buffer.asUint8List();
        signatureImage = pw.MemoryImage(signatureBytes);
      }
    } catch (e) {
      print('Sign loading failed: $e');
    }

    // Add page with exact formatting
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: buildLetterContent(data, letterType, logoImage, signatureImage, regularFont, boldFont),
        ),
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

  List<pw.Widget> buildLetterContent(LetterData data, LetterType letterType, pw.ImageProvider? logoImage, pw.ImageProvider? signatureImage, pw.Font regularFont, pw.Font boldFont) {
    final templateData = data.toTemplateData();
    
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return buildMalaysiaStudyTourInvitation(templateData, logoImage, signatureImage, regularFont, boldFont);
        
      case LetterType.passportRequestLetter:
        return buildPassportRequestLetter(templateData, logoImage, signatureImage, regularFont, boldFont);
        
      default:
        return buildDefaultLetter(templateData, letterType, logoImage, signatureImage, regularFont, boldFont);
    }
  }

  List<pw.Widget> buildMalaysiaStudyTourInvitation(Map<String, String> data, pw.ImageProvider? logoImage, pw.ImageProvider? signatureImage, pw.Font regularFont, pw.Font boldFont) {
    return [
      // Header with logo and organization info
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo section
          if (logoImage != null)
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.orange300,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  'MIYC',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ),
          
          pw.SizedBox(width: 20),
          
          // Organization header
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Malaysian Indian Youth Council (MIYC)',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                    color: PdfColors.red,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Majlis Belia India Malaysia',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 12,
                    color: PdfColors.red,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'No. 87, 2, Jln SBC 1, Taman Sri Batu Caves, 68100, Selangor,\nMalaysia',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 10,
                    color: PdfColors.red,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      
      pw.SizedBox(height: 25),
      
      // Variable data section in box
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 1),
        ),
        child: pw.Text(
          'To,\nMS.[name_with_initials], [identification_type]: [identification_number].\nSri Lanka.',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
            height: 1.4,
          ),
        ),
      ),
      
      pw.SizedBox(height: 20),
      
      // Date - right aligned
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '30-07-2025',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
          ),
        ),
      ),
      
      pw.SizedBox(height: 15),
      
      // Actual recipient information
      pw.Text(
        'To,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'MS. ${data['name']?.toUpperCase()}, ${data['identification_type'] == 'PASSPORT' ? 'Passport No' : 'NIC No'}: ${data['identification_number']}.',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Sri Lanka.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.SizedBox(height: 15),
      
      // Greeting
      pw.Text(
        'Dear Madam,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.SizedBox(height: 12),
      
      // Subject - underlined and bold
      pw.Text(
        'Invitation for the Child Educators Global Connect, Which will take place in Malaysia from 16th to 22nd September 2025.',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          decoration: pw.TextDecoration.underline,
        ),
      ),
      
      pw.SizedBox(height: 15),
      
      // First paragraph
      pw.Text(
        'We are delighted to invite MS. ${data['name']?.toUpperCase()}, ${data['identification_type'] == 'PASSPORT' ? 'Passport No' : 'NIC No'}: ${data['identification_number']} from Sri Lanka, as a Participant for the upcoming Child Educators Global Connect Programme, Which will take place in Malaysia from 16th to 22nd September 2025.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
          height: 1.4,
        ),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 12),
      
      // Second paragraph
      pw.Text(
        'The program, a flagship initiative of MIYC, aims to promote cultural and collaboration among professionals. It serves as a platform for participants to engage in meaningful interactions, develop leadership skills, and broaden their global perspectives.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
          height: 1.4,
        ),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 12),
      
      // Third paragraph
      pw.Text(
        'Your selection as the Sri Lankan Participant for the upcoming Child Educators Global Connect Programme is a testament to your exceptional qualifications, leadership abilities, and dedication to fostering cross-cultural understanding. We have full confidence that your commitment and enthusiasm will greatly contribute to the success of this programme. Our goal is to build a relationship between Sri Lanka and Malaysia, fostering understanding and collaboration. We extend our heartfelt congratulations to you and eagerly anticipate the positive impact you will bring to this enriching experience.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
          height: 1.4,
        ),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 12),
      
      // Fourth paragraph
      pw.Text(
        'We look forward to your participation and wish you continued success in your endeavours.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
          height: 1.4,
        ),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 15),
      
      // Contact information
      pw.Text(
        'For further enquiries please contact our focal point for Sri Lanka:',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Mr. Gayan Rajapaksha, Chairperson, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        '+94777138134, gayanraj@outlook.com',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Mr. Goyum Prabath Rupasena, Secretary, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        '+94718081831, goyum85@gmail.com',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.SizedBox(height: 20),
      
      // Closing
      pw.Text(
        'With high regards,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.SizedBox(height: 10),
      
      // Signature image
      if (signatureImage != null)
        pw.Container(
          width: 120,
          height: 40,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 25),
      
      pw.SizedBox(height: 10),
      
      // Signature section
      pw.Text(
        'DHANESH BASIL,',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'National President,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Malaysian Indian Youth Council (MIYC),',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Malaysia.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.Spacer(),
      
      // Updated Footer with proper black and white icons
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left: Website with globe icon
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // Globe icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '🌐',
                      style: pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'WWW.MIYC.COM.MY',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Center: Organization name
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              'MALAYSIAN INDIAN YOUTH COUNCIL',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          
          // Right: Social media with icons
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                // Facebook icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'f',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 7,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 3),
                pw.Text(
                  'FACEBOOK',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(width: 8),
                
                // Instagram icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '📷',
                      style: pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 3),
                pw.Text(
                  'INSTAGRAM',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 6,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<pw.Widget> buildPassportRequestLetter(Map<String, String> data, pw.ImageProvider? logoImage, pw.ImageProvider? signatureImage, pw.Font regularFont, pw.Font boldFont) {
    return [
      // Header with logo and organization info
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Logo section
          if (logoImage != null)
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logoImage, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.orange300,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text('MIYC', style: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.white)),
              ),
            ),
          
          pw.SizedBox(width: 15),
          
          // Organization header
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Malaysian Indian Youth Council (MIYC)',
                  style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColor.fromHex('#DC143C')),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  'Majlis Belia India Malaysia',
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: PdfColor.fromHex('#DC143C')),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'No. 87, 2, Jln SBC 1, Taman Sri Batu Caves, 68100, Selangor,\nMalaysia',
                  style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColor.fromHex('#DC143C')),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      
      pw.SizedBox(height: 15),
      
      // Yellow line across the width
      pw.Container(
        width: double.infinity,
        height: 3,
        color: PdfColor.fromHex('#FFD700'),
      ),
      
      pw.SizedBox(height: 15),
      
      // Date
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '30-07-2025',
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
          ),
        ),
      ),
      
      pw.SizedBox(height: 20),
      
      // Recipient
      pw.Text(
        'The Control (Travel) Officer',
        style: pw.TextStyle(font: boldFont, fontSize: 11),
      ),
      pw.Text(
        'Department of Immigration & Emigration',
        style: pw.TextStyle(font: boldFont, fontSize: 11),
      ),
      pw.Text(
        'Sri Lanka',
        style: pw.TextStyle(font: boldFont, fontSize: 11),
      ),
      
      pw.SizedBox(height: 15),
      
      pw.Text(
        'Dear Sir/Madam,',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      
      pw.SizedBox(height: 15),
      
      // Subject - underlined
      pw.Text(
        'Subject: Urgent Request for Passport Release',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          decoration: pw.TextDecoration.underline,
        ),
      ),
      
      pw.SizedBox(height: 15),
      
      pw.RichText(
        text: pw.TextSpan(
            style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.4),
            children: [
            pw.TextSpan(
                text: 'I am writing to request the urgent release of the passport for ',
            ),
            pw.TextSpan(
                text: 'MS. ${data['name_with_initials']?.toUpperCase()}',
                style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.4),
            ),
            pw.TextSpan(
                text: ', NIC No: ',
            ),
            pw.TextSpan(
                text: '${data['identification_number']}',
                style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.4),
            ),
            pw.TextSpan(
                text: ', who is scheduled to travel to Malaysia on 16th to 22nd September for a group study program with our partner, the \'Commonwealth Youth Network\'.',
            ),
            ],
        ),
        textAlign: pw.TextAlign.justify,
        ),

      pw.SizedBox(height: 12),
      
      pw.Text(
        'The passport is urgently required to proceed with further arrangements, including flight reservations, accommodation, and the visa application process. I kindly request your assistance in expediting the process and issuing the passport at your earliest convenience to ensure that the necessary preparations can be completed on time.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.4),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 12),
      
      pw.Text(
        'We would be extremely grateful if you could kindly arrange the need for her to receive the passport as soon as possible.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.4),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 12),
      
      pw.Text(
        'Thank you for your prompt attention to this matter.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.4),
        textAlign: pw.TextAlign.justify,
      ),
      
      pw.SizedBox(height: 15),
      
      // Contact details
      pw.Text(
        'For further enquiries please contact our focal point for Sri Lanka:',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Mr. Gayan Rajapaksha, Chairperson, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      pw.Text(
        '+94777138134, gayanraj@outlook.com',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Mr. Goyum Prabath Rupasena, Secretary, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      pw.Text(
        '+94718081831, goyum85@gmail.com',
        style: pw.TextStyle(font: regularFont, fontSize: 11),
      ),
      
      pw.SizedBox(height: 25),
      
      // Closing
      pw.Text(
        'With high regards,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      pw.SizedBox(height: 10),
      
      // Signature image
      if (signatureImage != null)
        pw.Container(
          width: 120,
          height: 40,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 25),
      
      pw.SizedBox(height: 10),
      
      // Signature section
      pw.Text(
        'DHANESH BASIL,',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'National President,',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Malaysian Indian Youth Council (MIYC),',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      pw.Text(
        'Malaysia.',
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 11,
        ),
      ),
      
      // Footer line
      pw.Container(
        width: double.infinity,
        height: 3,
        color: PdfColor.fromHex('#FFD700'),
      ),
      
      pw.SizedBox(height: 10),
      
      // Updated Footer with proper black and white icons
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left: Website with globe icon
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // Globe icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '🌐',
                      style: pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'WWW.MIYC.COM.MY',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // Globe icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '🌐',
                      style: pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'WWW.MIYC.COM.MY',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // Globe icon (black and white)
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '🌐',
                      style: pw.TextStyle(
                        fontSize: 6,
                        color: PdfColors.black,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'WWW.MIYC.COM.MY',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<pw.Widget> buildDefaultLetter(Map<String, String> data, LetterType letterType, pw.ImageProvider? logoImage, pw.ImageProvider? signatureImage, pw.Font regularFont, pw.Font boldFont) {
    return [
      pw.Center(
        child: pw.Text(
          _getLetterTitle(letterType),
          style: pw.TextStyle(fontSize: 16, font: boldFont),
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Text('Date: ${data['current_date']}', style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 20),
      pw.Text('Dear ${data['name']},', style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 15),
      pw.Text('Name with Initials: ${data['name_with_initials']}', style: pw.TextStyle(font: regularFont)),
      pw.Text('${data['identification_type']}: ${data['identification_number']}', style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 30),
      
      // Closing
      pw.Text('With high regards,', style: pw.TextStyle(font: regularFont)),
      
      pw.SizedBox(height: 10),
      
      // Signature image
      if (signatureImage != null)
        pw.Container(
          width: 240,
          height: 80,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 25),
      
      pw.SizedBox(height: 10),
      
      pw.Text('OFFICE L', style: pw.TextStyle(font: boldFont)),
    ];
  }

  String generateFileName(LetterData data, LetterType letterType) {
    final nameWithInitials = data.nameWithInitials;
    
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'Malaysia-Study-Tour-Invitation-${nameWithInitials}';
      case LetterType.passportRequestLetter:
        return 'Passport-Request-Letter-${nameWithInitials}';
      default:
        return '${_getLetterTitle(letterType)}-${nameWithInitials}';
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
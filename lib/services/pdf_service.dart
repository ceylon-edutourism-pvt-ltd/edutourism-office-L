import 'dart:io';
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
    // Load fonts
    final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    // Load MIYC logo
    pw.ImageProvider? logoImage;
    try {
      if (settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync()) {
        logoImage = pw.MemoryImage(await File(settings.logoPath).readAsBytes());
      } else {
        logoImage = pw.MemoryImage(
            (await rootBundle.load("assets/miyc_logo.jpg")).buffer.asUint8List());
      }
    } catch (e) {
      print('Logo loading failed: $e');
    }

    // Load signature
    pw.ImageProvider? signatureImage;
    try {
      if (settings.signaturePath.isNotEmpty && File(settings.signaturePath).existsSync()) {
        signatureImage = pw.MemoryImage(await File(settings.signaturePath).readAsBytes());
      } else {
        signatureImage = pw.MemoryImage(
            (await rootBundle.load("assets/signature.png")).buffer.asUint8List());
      }
    } catch (e) {
      print('Signature loading failed: $e');
    }

    // Load social icons
    pw.ImageProvider? fbIcon;
    pw.ImageProvider? igIcon;
    pw.ImageProvider? globeIcon;
    try {
      fbIcon = pw.MemoryImage(
          (await rootBundle.load("assets/icon_facebook.png")).buffer.asUint8List());
      igIcon = pw.MemoryImage(
          (await rootBundle.load("assets/icon_instagram.png")).buffer.asUint8List());
      globeIcon = pw.MemoryImage(
          (await rootBundle.load("assets/icon_globe.png")).buffer.asUint8List());
    } catch (e) {
      print('Social icon loading failed: $e');
    }

    // Build page
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: buildLetterContent(
              data, letterType, logoImage, signatureImage, fbIcon, igIcon, globeIcon,
              regularFont, boldFont),
        ),
      ),
    );

    // Save
    final fileName = generateFileName(data, letterType);
    final directory = settings.outputDirectory.isNotEmpty
        ? Directory(settings.outputDirectory)
        : await getApplicationDocumentsDirectory();

    final filePath = "${directory.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  List<pw.Widget> buildLetterContent(
      LetterData data,
      LetterType letterType,
      pw.ImageProvider? logoImage,
      pw.ImageProvider? signatureImage,
      pw.ImageProvider? fbIcon,
      pw.ImageProvider? igIcon,
      pw.ImageProvider? globeIcon,
      pw.Font regularFont,
      pw.Font boldFont) {
    final templateData = data.toTemplateData();

    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return buildMalaysiaStudyTourInvitation(
            templateData, logoImage, signatureImage, fbIcon, igIcon, globeIcon,
            regularFont, boldFont);
      case LetterType.passportRequestLetter:
        return buildPassportRequestLetter(
            templateData, logoImage, signatureImage, fbIcon, igIcon, globeIcon,
            regularFont, boldFont);
      case LetterType.leaveLetter:
        return buildLeaveRequestLetter(
            templateData, logoImage, signatureImage, fbIcon, igIcon, globeIcon,
            regularFont, boldFont);
      default:
        return buildDefaultLetter(
            templateData, letterType, logoImage, signatureImage,
            regularFont, boldFont);
    }
  }

  // ─── HEADER (logo left + org name centred + gold line bottom) ───────────
  List<pw.Widget> _buildHeader(
      pw.ImageProvider? logoImage, pw.Font regularFont, pw.Font boldFont) {
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Bigger logo
          pw.Container(
            width: 90,
            height: 90,
            child: logoImage != null
                ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                : pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.orange,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text('MIYC',
                          style: pw.TextStyle(
                              font: boldFont, fontSize: 16, color: PdfColors.white)),
                    ),
                  ),
          ),
          pw.SizedBox(width: 14),

          // Org text — perfectly centred in remaining width
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Malaysian Indian Youth Council (MIYC)',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 15,
                    color: PdfColor.fromHex('#DC143C'),
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Majlis Belia India Malaysia',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: PdfColor.fromHex('#DC143C'),
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'No. 87, 2, Jln SBC 1, Taman Sri Batu Caves, 68100, Selangor, Malaysia',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 9,
                    color: PdfColor.fromHex('#DC143C'),
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),

      pw.SizedBox(height: 7),
      // Single gold line at bottom of header
      pw.Container(
        width: double.infinity,
        height: 3,
        color: PdfColor.fromHex('#FFD700'),
      ),
    ];
  }

  // ─── FOOTER: globe+text | fb+text | ig+text (horizontal, dashed line above) ─
  pw.Widget _buildFooter(
      pw.ImageProvider? fbIcon,
      pw.ImageProvider? igIcon,
      pw.ImageProvider? globeIcon,
      pw.Font regularFont,
      pw.Font boldFont) {

    // helper: icon left + text right, horizontally
    pw.Widget _iconRow(pw.ImageProvider? icon, String fallback, String label) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 16, height: 16,
            child: icon != null
                ? pw.Image(icon, fit: pw.BoxFit.contain)
                : pw.Container(
                    decoration: pw.BoxDecoration(
                        color: PdfColors.black,
                        shape: pw.BoxShape.circle),
                    child: pw.Center(
                        child: pw.Text(fallback,
                            style: pw.TextStyle(font: boldFont, fontSize: 7, color: PdfColors.white)))),
          ),
          pw.SizedBox(width: 5),
          pw.Text(label,
              style: pw.TextStyle(font: boldFont, fontSize: 8, color: PdfColors.black)),
        ],
      );
    }

    return pw.Column(
      children: [
        // Dashed separator line (simulated with thin container)
        pw.Container(
          width: double.infinity, height: 0.8,
          color: PdfColors.grey600,
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // LEFT: Globe + WWW.MIYC.COM.MY
            _iconRow(globeIcon, 'W', 'WWW.MIYC.COM.MY'),

            // CENTRE: FB + MALAYSIAN YOUTH COUNCIL
            _iconRow(fbIcon, 'f', 'MALAYSIAN YOUTH COUNCIL'),

            // RIGHT: IG + MALAYSIAN YOUTH COUNCIL
            _iconRow(igIcon, 'ig', 'MALAYSIAN YOUTH COUNCIL'),
          ],
        ),
      ],
    );
  }

  // ─── MALAYSIA STUDY TOUR INVITATION ───────────────────────────────────────
  List<pw.Widget> buildMalaysiaStudyTourInvitation(
      Map<String, String> data,
      pw.ImageProvider? logoImage,
      pw.ImageProvider? signatureImage,
      pw.ImageProvider? fbIcon,
      pw.ImageProvider? igIcon,
      pw.ImageProvider? globeIcon,
      pw.Font regularFont,
      pw.Font boldFont) {
    final nameWithInitials = data['name_with_initials'] ?? '';
    final idType = data['identification_type'] == 'PASSPORT' ? 'Passport No' : 'NIC No';
    final idNumber = data['identification_number'] ?? '';
    final titlePrefix = data['title_prefix'] ?? 'MS.';
    final salutation = data['salutation'] ?? 'Dear Madam,';

    final day = data['current_day'] ?? '';
    final month = data['current_month'] ?? '';
    final year = data['current_year'] ?? '';
    final dateStr =
        '${day.padLeft(2, '0')}-${_monthNumber(month).toString().padLeft(2, '0')}-$year';

    return [
      // ── Header
      ..._buildHeader(logoImage, regularFont, boldFont),

      pw.SizedBox(height: 18),

      // ── Date (right-aligned, before "To,")
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          dateStr,
          style: pw.TextStyle(font: regularFont, fontSize: 11),
        ),
      ),

      pw.SizedBox(height: 14),

      // ── Recipient address
      pw.Text('To,', style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text(
        '$titlePrefix $nameWithInitials,',
        style: pw.TextStyle(font: boldFont, fontSize: 11),
      ),
      pw.Text(
        '$idType: $idNumber.',
        style: pw.TextStyle(font: boldFont, fontSize: 11),
      ),
      pw.SizedBox(height: 10),
      pw.Text('Sri Lanka.', style: pw.TextStyle(font: boldFont, fontSize: 11)),

      pw.SizedBox(height: 14),

      // ── Salutation
      pw.Text(salutation, style: pw.TextStyle(font: regularFont, fontSize: 11)),

      pw.SizedBox(height: 12),

      // ── Subject (bold + underline)
      pw.Text(
        'Invitation for the Child Educators Global Connect, Which will take place in Malaysia from 16th to 22nd September 2025.',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          decoration: pw.TextDecoration.underline,
        ),
      ),

      pw.SizedBox(height: 12),

      // ── Para 1: name + ID on ONE line (bold)
      pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
          children: [
            const pw.TextSpan(text: 'We are delighted to invite '),
            pw.TextSpan(
              text: '$titlePrefix $nameWithInitials, $idType: $idNumber',
              style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.6),
            ),
            const pw.TextSpan(
              text: ' from Sri Lanka, as a Participant for the upcoming Child Educators Global Connect Programme, Which will take place in Malaysia from 16th to 22nd September 2025.',
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 10),

      // ── Para 2
      pw.Text(
        'The program, a flagship initiative of MIYC, aims to promote cultural and collaboration among professionals. It serves as a platform for participants to engage in meaningful interactions, develop leadership skills, and broaden their global perspectives.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      // ── Para 3
      pw.Text(
        'Your selection as the Sri Lankan Participant for the upcoming Child Educators Global Connect Programme is a testament to your exceptional qualifications, leadership abilities, and dedication to fostering cross-cultural understanding. We have full confidence that your commitment and enthusiasm will greatly contribute to the success of this programme. Our goal is to build a relationship between Sri Lanka and Malaysia, fostering understanding and collaboration. We extend our heartfelt congratulations to you and eagerly anticipate the positive impact you will bring to this enriching experience.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      // ── Para 4
      pw.Text(
        'We look forward to your participation and wish you continued success in your endeavours.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 14),

      // ── Contact info with hyperlink emails
      pw.Text(
        'For further enquiries please contact our focal point for Sri Lanka:',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Gayan Rajapaksha, Chairperson, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94777138134, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:gayanraj@outlook.com',
          child: pw.Text('gayanraj@outlook.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Goyum Prabath Rupasena, Secretary, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94718081831, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:goyum85@gmail.com',
          child: pw.Text('goyum85@gmail.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),

      pw.SizedBox(height: 18),

      // ── Closing
      pw.Text('With high regards,', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),

      pw.SizedBox(height: 8),

      // ── Signature image — bigger
      if (signatureImage != null)
        pw.Container(
          width: 130,
          height: 60,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 40),

      pw.SizedBox(height: 4),

      // ── Signatory
      pw.Text('DHANESH BASIL,',
          style: pw.TextStyle(font: boldFont, fontSize: 11)),
      pw.Text('National President,',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysian Indian Youth Council (MIYC),',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysia.',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),

      pw.Spacer(),

      // ── Footer
      _buildFooter(fbIcon, igIcon, globeIcon, regularFont, boldFont),
    ];
  }

  // ─── PASSPORT REQUEST LETTER ───────────────────────────────────────────────
  List<pw.Widget> buildPassportRequestLetter(
      Map<String, String> data,
      pw.ImageProvider? logoImage,
      pw.ImageProvider? signatureImage,
      pw.ImageProvider? fbIcon,
      pw.ImageProvider? igIcon,
      pw.ImageProvider? globeIcon,
      pw.Font regularFont,
      pw.Font boldFont) {
    final nameWithInitials = data['name_with_initials'] ?? '';
    final idNumber = data['identification_number'] ?? '';
    // Passport Request Letter ALWAYS uses NIC
    final titlePrefix = data['title_prefix'] ?? 'MS.';
    final pronounObject = data['pronoun_object'] ?? 'her';

    final day = data['current_day'] ?? '';
    final month = data['current_month'] ?? '';
    final year = data['current_year'] ?? '';
    final dateStr =
        '${day.padLeft(2, '0')}-${_monthNumber(month).toString().padLeft(2, '0')}-$year';

    return [
      // ── Header
      ..._buildHeader(logoImage, regularFont, boldFont),

      pw.SizedBox(height: 18),

      // ── Date
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(dateStr,
            style: pw.TextStyle(font: regularFont, fontSize: 11)),
      ),

      pw.SizedBox(height: 18),

      // ── Recipient
      pw.Text('The Control (Travel) Officer',
          style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.6)),
      pw.Text('Department of Immigration & Emigration',
          style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.6)),
      pw.Text('Sri Lanka',
          style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.6)),

      pw.SizedBox(height: 14),

      pw.Text('Dear Sir/Madam,',
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),

      pw.SizedBox(height: 14),

      // ── Subject
      pw.Text(
        'Subject: Urgent Request for Passport Release',
        style: pw.TextStyle(
          font: boldFont, fontSize: 11,
          decoration: pw.TextDecoration.underline,
        ),
      ),

      pw.SizedBox(height: 14),

      // ── Para 1: NIC No always used here
      pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
          children: [
            const pw.TextSpan(
                text: 'I am writing to request the urgent release of the passport for '),
            pw.TextSpan(
              text: '$titlePrefix $nameWithInitials, NIC No: $idNumber',
              style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.6),
            ),
            const pw.TextSpan(
              text: ", who is scheduled to travel to Malaysia on 16th to 22nd September for a group study program with our partner, the 'Commonwealth Youth Network'.",
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'The passport is urgently required to proceed with further arrangements, including flight reservations, accommodation, and the visa application process. I kindly request your assistance in expediting the process and issuing the passport at your earliest convenience to ensure that the necessary preparations can be completed on time.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'We would be extremely grateful if you could kindly arrange the need for $pronounObject to receive the passport as soon as possible.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'Thank you for your prompt attention to this matter.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 14),

      // ── Contact info with hyperlink emails
      pw.Text(
        'For further enquiries please contact our focal point for Sri Lanka:',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Gayan Rajapaksha, Chairperson, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94777138134, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:gayanraj@outlook.com',
          child: pw.Text('gayanraj@outlook.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Goyum Prabath Rupasena, Secretary, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94718081831, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:goyum85@gmail.com',
          child: pw.Text('goyum85@gmail.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),

      pw.SizedBox(height: 20),

      pw.Text('With high regards,',
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),

      pw.SizedBox(height: 8),

      if (signatureImage != null)
        pw.Container(
          width: 130, height: 60,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 40),

      pw.SizedBox(height: 4),

      pw.Text('DHANESH BASIL,',
          style: pw.TextStyle(font: boldFont, fontSize: 11)),
      pw.Text('National President,',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysian Indian Youth Council (MIYC),',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysia.',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),

      pw.Spacer(),

      // ── Footer
      _buildFooter(fbIcon, igIcon, globeIcon, regularFont, boldFont),
    ];
  }

  // ─── LEAVE REQUEST LETTER ─────────────────────────────────────────────────
  List<pw.Widget> buildLeaveRequestLetter(
      Map<String, String> data,
      pw.ImageProvider? logoImage,
      pw.ImageProvider? signatureImage,
      pw.ImageProvider? fbIcon,
      pw.ImageProvider? igIcon,
      pw.ImageProvider? globeIcon,
      pw.Font regularFont,
      pw.Font boldFont) {
    final nameWithInitials = data['name_with_initials'] ?? '';
    final idNumber = data['identification_number'] ?? '';
    final idType = data['identification_type'] == 'PASSPORT' ? 'Passport No' : 'NIC No';
    final titlePrefix = data['title_prefix'] ?? 'MR.';
    final pronounObject = data['pronoun_object'] ?? 'him';
    final pronounPossessive = data['pronoun_possessive'] ?? 'his';

    final day = data['current_day'] ?? '';
    final month = data['current_month'] ?? '';
    final year = data['current_year'] ?? '';
    final dateStr =
        '${day.padLeft(2, '0')}-${_monthNumber(month).toString().padLeft(2, '0')}-$year';

    final recipientName = data['recipient_name'] ?? '';
    final recipientTitle = data['recipient_title'] ?? '';
    final recipientOrg = data['recipient_organization'] ?? '';
    final recipientAddr = data['recipient_address'] ?? '';

    return [
      // ── Header
      ..._buildHeader(logoImage, regularFont, boldFont),

      pw.SizedBox(height: 18),

      // ── Date (right-aligned)
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(dateStr,
            style: pw.TextStyle(font: regularFont, fontSize: 11)),
      ),

      pw.SizedBox(height: 14),

      // ── Recipient address block
      pw.Text('To,', style: pw.TextStyle(font: regularFont, fontSize: 11)),
      if (recipientName.isNotEmpty)
        pw.Text(recipientName,
            style: pw.TextStyle(font: boldFont, fontSize: 11)),
      if (recipientTitle.isNotEmpty)
        pw.Text(recipientTitle,
            style: pw.TextStyle(font: regularFont, fontSize: 11)),
      if (recipientOrg.isNotEmpty)
        pw.Text(recipientOrg,
            style: pw.TextStyle(font: regularFont, fontSize: 11)),
      if (recipientAddr.isNotEmpty)
        pw.Text(recipientAddr,
            style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.SizedBox(height: 10),
      pw.Text('Sri Lanka.', style: pw.TextStyle(font: boldFont, fontSize: 11)),

      pw.SizedBox(height: 14),

      pw.Text('Dear Sir/Madam,',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),

      pw.SizedBox(height: 12),

      // ── Subject
      pw.Text(
        'Request for Leave to Facilitate Visa Arrangements.',
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 11,
          decoration: pw.TextDecoration.underline,
        ),
      ),

      pw.SizedBox(height: 12),

      // ── Para 1
      pw.RichText(
        textAlign: pw.TextAlign.justify,
        text: pw.TextSpan(
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.5),
          children: [
            const pw.TextSpan(
                text: 'I am writing to formally request leave on behalf of '),
            pw.TextSpan(
              text: '$titlePrefix $nameWithInitials ($idType: $idNumber)',
              style: pw.TextStyle(font: boldFont, fontSize: 11, height: 1.5),
            ),
            pw.TextSpan(
              text: ' for the purpose of facilitating $pronounObject travel arrangements to Malaysia from 16th to 22nd September as part of a group study program with our partner, the Commonwealth Youth Network.',
            ),
          ],
        ),
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'The leave is required to complete the visa application process. To ensure these preparations are completed on time, ${pronounPossessive} leave approval letter must be urgently collected and submitted.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.5),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'We kindly request your approval of this leave request to enable ${pronounObject} to meet the necessary deadlines for ${pronounPossessive} travel. Your prompt attention to this matter will be greatly appreciated.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.5),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 10),

      pw.Text(
        'Thank you for your understanding and support.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.5),
        textAlign: pw.TextAlign.justify,
      ),

      pw.SizedBox(height: 14),

      // ── Contact info with hyperlink emails
      pw.Text(
        'For further enquiries please contact our focal point for Sri Lanka:',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Gayan Rajapaksha, Chairperson, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94777138134, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:gayanraj@outlook.com',
          child: pw.Text('gayanraj@outlook.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),
      pw.SizedBox(height: 4),
      pw.Text(
        'Mr. Goyum Prabath Rupasena, Secretary, Commonwealth Youth Network of Sri Lanka.',
        style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6),
      ),
      pw.Row(children: [
        pw.Text('+94718081831, ', style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),
        pw.UrlLink(
          destination: 'mailto:goyum85@gmail.com',
          child: pw.Text('goyum85@gmail.com',
              style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6,
                  color: PdfColors.blue, decoration: pw.TextDecoration.underline)),
        ),
      ]),

      pw.SizedBox(height: 20),

      pw.Text('With high regards,',
          style: pw.TextStyle(font: regularFont, fontSize: 11, height: 1.6)),

      pw.SizedBox(height: 8),

      if (signatureImage != null)
        pw.Container(
          width: 130, height: 60,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 40),

      pw.SizedBox(height: 4),

      pw.Text('DHANESH BASIL,',
          style: pw.TextStyle(font: boldFont, fontSize: 11)),
      pw.Text('National President,',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysian Indian Youth Council (MIYC),',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),
      pw.Text('Malaysia.',
          style: pw.TextStyle(font: regularFont, fontSize: 11)),

      pw.Spacer(),

      // ── Footer
      _buildFooter(fbIcon, igIcon, globeIcon, regularFont, boldFont),
    ];
  }

  // ─── DEFAULT / PLACEHOLDER LETTER ─────────────────────────────────────────
  List<pw.Widget> buildDefaultLetter(
      Map<String, String> data,
      LetterType letterType,
      pw.ImageProvider? logoImage,
      pw.ImageProvider? signatureImage,
      pw.Font regularFont,
      pw.Font boldFont) {
    return [
      pw.Center(
        child: pw.Text(
          _getLetterTitle(letterType),
          style: pw.TextStyle(fontSize: 16, font: boldFont),
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Text('Date: ${data['current_date']}',
          style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 20),
      pw.Text('Dear ${data['name']},',
          style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 15),
      pw.Text('Name with Initials: ${data['name_with_initials']}',
          style: pw.TextStyle(font: regularFont)),
      pw.Text(
          '${data['identification_type']}: ${data['identification_number']}',
          style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 30),
      pw.Text('With high regards,', style: pw.TextStyle(font: regularFont)),
      pw.SizedBox(height: 10),
      if (signatureImage != null)
        pw.Container(
          width: 100,
          height: 45,
          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
        )
      else
        pw.SizedBox(height: 25),
      pw.SizedBox(height: 10),
      pw.Text('DHANESH BASIL,', style: pw.TextStyle(font: boldFont)),
      pw.Text('National President,', style: pw.TextStyle(font: regularFont)),
      pw.Text('Malaysian Indian Youth Council (MIYC),',
          style: pw.TextStyle(font: regularFont)),
      pw.Text('Malaysia.', style: pw.TextStyle(font: regularFont)),
    ];
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  int _monthNumber(String monthName) {
    const months = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4,
      'May': 5, 'June': 6, 'July': 7, 'August': 8,
      'September': 9, 'October': 10, 'November': 11, 'December': 12,
    };
    return months[monthName] ?? 1;
  }

  String generateFileName(LetterData data, LetterType letterType) {
    final nameWithInitials = data.nameWithInitials;
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'Malaysia-Study-Tour-Invitation-$nameWithInitials';
      case LetterType.passportRequestLetter:
        return 'Passport-Request-Letter-$nameWithInitials';
      default:
        return '${_getLetterTitle(letterType)}-$nameWithInitials';
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
      await Process.start('cmd', ['/c', 'start', '""', filePath],
          runInShell: true);
    } else if (Platform.isLinux) {
      await Process.start('xdg-open', [filePath], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [filePath], runInShell: true);
    }
  }
}

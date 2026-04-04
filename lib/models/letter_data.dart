import 'package:flutter/material.dart';

enum LetterType {
  malaysiaStudyTourInvitation,
  passportRequestLetter,
  invitationLetter,
  visaRequestLetter,
  leaveLetter,
  sponsorshipLetter,
  dependentLetter,
  freelancerLetter,
  employmentConfirmationLetter,
}

enum IdentificationType {
  passport,
  nic,
}

enum Gender {
  male,
  female,
}

class LetterData {
  String name;
  IdentificationType identificationType;
  String identificationNumber;
  Set<LetterType> selectedLetterTypes;
  Gender gender;

  // Dynamic fields
  String sponsorName;
  String dependentName;
  String occupation;
  String projectDetails;
  String contractDetails;

  // Leave letter fields
  String recipientName;
  String recipientTitle;
  String recipientOrganization;
  String recipientAddress;

  LetterData({
    this.name = '',
    this.identificationType = IdentificationType.passport,
    this.identificationNumber = '',
    Set<LetterType>? selectedLetterTypes,
    this.gender = Gender.female,
    this.sponsorName = '',
    this.dependentName = '',
    this.occupation = '',
    this.projectDetails = '',
    this.contractDetails = '',
    this.recipientName = '',
    this.recipientTitle = '',
    this.recipientOrganization = '',
    this.recipientAddress = '',
  }) : selectedLetterTypes = selectedLetterTypes ?? <LetterType>{};

  bool get requiresLeaveFields =>
      selectedLetterTypes.contains(LetterType.leaveLetter);

  bool get requiresSponsorFields =>
      selectedLetterTypes.contains(LetterType.dependentLetter) ||
      selectedLetterTypes.contains(LetterType.sponsorshipLetter);

  bool get requiresOccupationFields =>
      selectedLetterTypes.contains(LetterType.freelancerLetter) ||
      selectedLetterTypes.contains(LetterType.employmentConfirmationLetter);

  // Convert full name to initials format
  String get nameWithInitials {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length <= 1) return name.toUpperCase();
    
    final initials = parts.sublist(0, parts.length - 1)
        .map((part) => '${part[0].toUpperCase()}.')
        .join('');
    final lastName = parts.last.toUpperCase();
    
    return '$initials$lastName';
  }

  // Convert to template data map
  Map<String, String> toTemplateData() {
    return {
      'name': name,
      'name_with_initials': nameWithInitials,
      'identification_type': identificationType.name.toUpperCase(),
      'identification_number': identificationNumber,
      'gender': gender.name,
      'salutation': gender == Gender.female ? 'Dear Madam,' : 'Dear Sir,',
      'title_prefix': gender == Gender.female ? 'MS.' : 'MR.',
      'pronoun_subject': gender == Gender.female ? 'she' : 'he',
      'pronoun_object': gender == Gender.female ? 'her' : 'him',
      'pronoun_possessive': gender == Gender.female ? 'her' : 'his',
      'sponsor_name': sponsorName,
      'dependent_name': dependentName,
      'occupation': occupation,
      'project_details': projectDetails,
      'contract_details': contractDetails,
      'recipient_name': recipientName,
      'recipient_title': recipientTitle,
      'recipient_organization': recipientOrganization,
      'recipient_address': recipientAddress,
      'current_date': DateTime.now().toString().split(' ')[0],
      'current_year': DateTime.now().year.toString(),
      'current_month': _getMonthName(DateTime.now().month),
      'current_day': DateTime.now().day.toString(),
    };
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class BulkLetterData {
  final String name;
  final String identificationNumber;
  final IdentificationType identificationType;
  final Gender gender;

  BulkLetterData({
    required this.name,
    required this.identificationNumber,
    this.identificationType = IdentificationType.nic,
    this.gender = Gender.female,
  });
}

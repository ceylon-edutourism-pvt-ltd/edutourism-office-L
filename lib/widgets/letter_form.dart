import 'package:flutter/material.dart';
import '../models/letter_data.dart';

class LetterForm extends StatelessWidget {
  final LetterData letterData;
  final Function(LetterData) onDataChanged;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const LetterForm({
    Key? key,
    required this.letterData,
    required this.onDataChanged,
    required this.onGenerate,
    required this.isGenerating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field with initials preview
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  helperText: 'Enter full name (e.g., ethugala arachchi tharusha gimsara)',
                ),
                onChanged: (value) {
                  letterData.name = value;
                  onDataChanged(letterData);
                },
              ),
              if (letterData.name.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Name with Initials: ${letterData.nameWithInitials}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Gender selector
          Row(
            children: [
              const Text('Gender: '),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Female'),
                selected: letterData.gender == Gender.female,
                onSelected: (selected) {
                  if (selected) {
                    letterData.gender = Gender.female;
                    onDataChanged(letterData);
                  }
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Male'),
                selected: letterData.gender == Gender.male,
                onSelected: (selected) {
                  if (selected) {
                    letterData.gender = Gender.male;
                    onDataChanged(letterData);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Identification type
          Row(
            children: [
              const Text('Identification Type: '),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('Passport'),
                selected: letterData.identificationType == IdentificationType.passport,
                onSelected: (selected) {
                  if (selected) {
                    letterData.identificationType = IdentificationType.passport;
                    onDataChanged(letterData);
                  }
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('NIC'),
                selected: letterData.identificationType == IdentificationType.nic,
                onSelected: (selected) {
                  if (selected) {
                    letterData.identificationType = IdentificationType.nic;
                    onDataChanged(letterData);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Identification number
          TextFormField(
            decoration: InputDecoration(
              labelText: '${letterData.identificationType == IdentificationType.passport ? 'Passport' : 'NIC'} Number *',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              letterData.identificationNumber = value;
              onDataChanged(letterData);
            },
          ),

          // NIC warning for passport request letter
          if (letterData.selectedLetterTypes.contains(LetterType.passportRequestLetter) &&
              letterData.identificationType == IdentificationType.passport) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Passport Request Letter requires a NIC number. Please switch to NIC above.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Letter types
          const Text(
            'Select Letter Types:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...LetterType.values.map((letterType) {
            return CheckboxListTile(
              title: Text(_getLetterTypeName(letterType)),
              subtitle: letterType == LetterType.malaysiaStudyTourInvitation || 
                        letterType == LetterType.passportRequestLetter
                  ? const Text('Uses asset template', style: TextStyle(color: Colors.green, fontSize: 12))
                  : const Text('Uses default template', style: TextStyle(color: Colors.orange, fontSize: 12)),
              value: letterData.selectedLetterTypes.contains(letterType),
              onChanged: (checked) {
                if (checked == true) {
                  letterData.selectedLetterTypes.add(letterType);
                } else {
                  letterData.selectedLetterTypes.remove(letterType);
                }
                onDataChanged(letterData);
              },
            );
          }).toList(),

          // Dynamic fields for leave letter
          if (letterData.requiresLeaveFields) ...[
            const SizedBox(height: 16),
            const Text(
              'Leave Letter - Recipient Details:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Recipient Name (e.g., Ms. Amani Madarasinghe)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.recipientName = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Recipient Title (e.g., Human Resources Manager)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.recipientTitle = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.recipientOrganization = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Organization Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                letterData.recipientAddress = value;
                onDataChanged(letterData);
              },
            ),
          ],

          // Dynamic fields for sponsor
          if (letterData.requiresSponsorFields) ...[
            const SizedBox(height: 16),
            const Text(
              'Sponsor Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Sponsor Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.sponsorName = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dependent Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.dependentName = value;
                onDataChanged(letterData);
              },
            ),
          ],

          // Dynamic fields for occupation
          if (letterData.requiresOccupationFields) ...[
            const SizedBox(height: 16),
            const Text(
              'Occupation Information:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Occupation',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                letterData.occupation = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                letterData.projectDetails = value;
                onDataChanged(letterData);
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Contract Details',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                letterData.contractDetails = value;
                onDataChanged(letterData);
              },
            ),
          ],

          const SizedBox(height: 24),

          // Generate button
          ElevatedButton.icon(
            onPressed: isGenerating ? null : onGenerate,
            icon: isGenerating 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(isGenerating ? 'Generating PDF...' : 'Generate PDF Letters'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getLetterTypeName(LetterType letterType) {
    switch (letterType) {
      case LetterType.malaysiaStudyTourInvitation:
        return 'Malaysia Study Tour Invitation';
      case LetterType.passportRequestLetter:
        return 'Passport Request Letter';
      case LetterType.invitationLetter:
        return 'Invitation Letter';
      case LetterType.visaRequestLetter:
        return 'Visa Request Letter';
      case LetterType.leaveLetter:
        return 'Leave Letter';
      case LetterType.sponsorshipLetter:
        return 'Sponsorship Letter';
      case LetterType.dependentLetter:
        return 'Dependent Letter';
      case LetterType.freelancerLetter:
        return 'Freelancer Letter';
      case LetterType.employmentConfirmationLetter:
        return 'Employment Confirmation Letter';
    }
  }
}

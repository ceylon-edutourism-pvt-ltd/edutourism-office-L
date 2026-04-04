import 'package:flutter/material.dart';
import '../models/letter_data.dart';

class BulkModeWidget extends StatefulWidget {
  final List<BulkLetterData> bulkLetters;
  final Function(List<BulkLetterData>) onBulkLettersChanged;
  final LetterData letterData;
  final Function(LetterData) onLetterDataChanged;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const BulkModeWidget({
    Key? key,
    required this.bulkLetters,
    required this.onBulkLettersChanged,
    required this.letterData,
    required this.onLetterDataChanged,
    required this.onGenerate,
    required this.isGenerating,
  }) : super(key: key);

  @override
  State<BulkModeWidget> createState() => _BulkModeWidgetState();
}

class _BulkModeWidgetState extends State<BulkModeWidget> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  IdentificationType _selectedIdType = IdentificationType.nic;
  Gender _selectedGender = Gender.female;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.group, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Bulk Mode - Generate Multiple Letters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add multiple people to generate letters for all at once with one click.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Add new entry form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Person:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Row 1: Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., john doe smith',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  // Preview initials
                  if (_nameController.text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Preview: ${_getInitialsFromName(_nameController.text)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Row 2: Gender + ID Type + ID Number + Add button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Gender toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          ToggleButtons(
                            isSelected: [
                              _selectedGender == Gender.female,
                              _selectedGender == Gender.male,
                            ],
                            onPressed: (i) => setState(() {
                              _selectedGender = i == 0 ? Gender.female : Gender.male;
                            }),
                            borderRadius: BorderRadius.circular(8),
                            constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('F', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('M', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 10),

                      // ID Type toggle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ID Type:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          ToggleButtons(
                            isSelected: [
                              _selectedIdType == IdentificationType.nic,
                              _selectedIdType == IdentificationType.passport,
                            ],
                            onPressed: (i) => setState(() {
                              _selectedIdType = i == 0 ? IdentificationType.nic : IdentificationType.passport;
                            }),
                            borderRadius: BorderRadius.circular(8),
                            constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('NIC', style: TextStyle(fontSize: 12)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Text('Pass', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(width: 10),

                      // ID Number field
                      Expanded(
                        child: TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: _selectedIdType == IdentificationType.nic ? 'NIC Number' : 'Passport No',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Add button
                      ElevatedButton.icon(
                        onPressed: _addBulkEntry,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // People list header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'People Added (${widget.bulkLetters.length}):',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (widget.bulkLetters.isNotEmpty)
                TextButton.icon(
                  onPressed: () => widget.onBulkLettersChanged([]),
                  icon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
                  label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // People list
          SizedBox(
            height: 200,
            child: widget.bulkLetters.isEmpty
                ? Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No people added yet',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text('Add names above to generate bulk letters',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.bulkLetters.length,
                    itemBuilder: (context, index) {
                      final item = widget.bulkLetters[index];
                      final initials = _getInitialsFromName(item.name);
                      final idLabel = item.identificationType == IdentificationType.nic ? 'NIC' : 'Pass';
                      final genderLabel = item.gender == Gender.female ? 'F' : 'M';
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.gender == Gender.female
                                ? Colors.pink.shade100
                                : Colors.blue.shade100,
                            child: Text(
                              genderLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.gender == Gender.female
                                    ? Colors.pink.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                          title: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('$idLabel: ${item.identificationNumber}  |  ${item.name}',
                              style: const TextStyle(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _removeBulkEntry(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),

          // Letter type selection
          const Text(
            'Select Letter Types:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: LetterType.values.map((letterType) {
                  return CheckboxListTile(
                    dense: true,
                    title: Text(_getLetterTypeName(letterType)),
                    value: widget.letterData.selectedLetterTypes.contains(letterType),
                    onChanged: (checked) {
                      if (checked == true) {
                        widget.letterData.selectedLetterTypes.add(letterType);
                      } else {
                        widget.letterData.selectedLetterTypes.remove(letterType);
                      }
                      widget.onLetterDataChanged(widget.letterData);
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Generate ALL button
          ElevatedButton.icon(
            onPressed: widget.isGenerating || widget.bulkLetters.isEmpty ||
                widget.letterData.selectedLetterTypes.isEmpty
                ? null
                : widget.onGenerate,
            icon: widget.isGenerating
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.picture_as_pdf),
            label: Text(
              widget.isGenerating
                  ? 'Generating...'
                  : 'Generate All  (${widget.bulkLetters.length} people × '
                      '${widget.letterData.selectedLetterTypes.length} types = '
                      '${widget.bulkLetters.length * widget.letterData.selectedLetterTypes.length} files)',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _addBulkEntry() {
    if (_nameController.text.isNotEmpty && _idController.text.isNotEmpty) {
      final newEntry = BulkLetterData(
        name: _nameController.text.trim(),
        identificationNumber: _idController.text.trim(),
        identificationType: _selectedIdType,
        gender: _selectedGender,
      );
      final updatedList = List<BulkLetterData>.from(widget.bulkLetters)..add(newEntry);
      widget.onBulkLettersChanged(updatedList);
      _nameController.clear();
      _idController.clear();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both name and ID number'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeBulkEntry(int index) {
    final updatedList = List<BulkLetterData>.from(widget.bulkLetters)..removeAt(index);
    widget.onBulkLettersChanged(updatedList);
  }

  String _getInitialsFromName(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length <= 1) return name.toUpperCase();
    final initials = parts.sublist(0, parts.length - 1)
        .map((part) => '${part[0].toUpperCase()}.')
        .join('');
    final lastName = parts.last.toUpperCase();
    return '$initials$lastName';
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

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }
}

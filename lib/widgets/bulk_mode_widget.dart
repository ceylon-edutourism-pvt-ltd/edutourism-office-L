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

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
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
                  'Add multiple names to generate letters for all at once. Names will be converted to initials format automatically.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., john doe smith',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'NIC/Passport',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addBulkEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                
                // Preview initials
                if (_nameController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Preview: ${_getInitialsPreview(_nameController.text)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // List of added entries
        Text(
          'Added People (${widget.bulkLetters.length}):',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // FIXED: Use SizedBox with height instead of Expanded
        SizedBox(
          height: 200, // Fixed height for people list
          child: widget.bulkLetters.isEmpty
              ? Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, 
                             size: 48, color: Colors.grey.shade400), // Reduced size
                        const SizedBox(height: 8), // Reduced spacing
                        Text(
                          'No people added yet',
                          style: TextStyle(
                            fontSize: 14, 
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add names above to generate bulk letters',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.bulkLetters.length,
                  itemBuilder: (context, index) {
                    final item = widget.bulkLetters[index];
                    final initials = _getInitialsFromName(item.name);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            initials.split('.').first + (initials.split('.').length > 1 ? initials.split('.')[1][0] : ''),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${item.identificationNumber}'),
                            Text(
                              'Initials: $initials',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeBulkEntry(index),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 16),

        // Letter type selection
        const Text(
          'Select Letter Types for Bulk Generation:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // FIXED: Reduced height and made it more compact
        SizedBox(
          height: 150, // Reduced from 200
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView(
                children: LetterType.values.map((letterType) {
                  return CheckboxListTile(
                    dense: true, // Make it more compact
                    title: Text(_getLetterTypeName(letterType)),
                    subtitle: letterType == LetterType.malaysiaStudyTourInvitation || 
                              letterType == LetterType.passportRequestLetter
                        ? const Text('Uses asset template', style: TextStyle(color: Colors.green, fontSize: 11))
                        : const Text('Uses default template', style: TextStyle(color: Colors.orange, fontSize: 11)),
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
        ),

        const SizedBox(height: 16),

        // Generate button
        ElevatedButton.icon(
          onPressed: widget.isGenerating || widget.bulkLetters.isEmpty ? null : widget.onGenerate,
          icon: widget.isGenerating 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(widget.isGenerating 
              ? 'Generating PDF Letters...' 
              : 'Generate ${widget.bulkLetters.length} PDF Letter(s)'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(fontSize: 16),
            backgroundColor: widget.bulkLetters.isEmpty ? Colors.grey : null,
          ),
        ),

        const SizedBox(height: 16), // Add bottom padding
      ],
    ),
  );
}


  void _addBulkEntry() {
    if (_nameController.text.isNotEmpty && _idController.text.isNotEmpty) {
      final newEntry = BulkLetterData(
        name: _nameController.text.trim(),
        identificationNumber: _idController.text.trim(),
      );
      
      final updatedList = List<BulkLetterData>.from(widget.bulkLetters);
      updatedList.add(newEntry);
      widget.onBulkLettersChanged(updatedList);
      
      _nameController.clear();
      _idController.clear();
      setState(() {}); // Refresh preview
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both name and identification number'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeBulkEntry(int index) {
    final updatedList = List<BulkLetterData>.from(widget.bulkLetters);
    updatedList.removeAt(index);
    widget.onBulkLettersChanged(updatedList);
  }

  String _getInitialsPreview(String name) {
    return _getInitialsFromName(name);
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

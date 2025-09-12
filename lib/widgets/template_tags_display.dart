import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/letter_data.dart';

class TemplateTagsDisplay extends StatelessWidget {
  final List<String> availableTags;
  final bool showStandardTags;

  const TemplateTagsDisplay({
    Key? key,
    required this.availableTags,
    this.showStandardTags = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final standardTags = [
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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.label, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Available Template Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (availableTags.isNotEmpty) ...[
            const Text(
              'Tags found in your templates:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: availableTags.map((tag) => _buildTagChip(context, tag, Colors.green)).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
          ],
          
          if (showStandardTags) ...[
            const Text(
              'Standard available tags:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: standardTags.map((tag) => _buildTagChip(context, tag, Colors.blue)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          const Text(
            'Tap any tag to copy it to clipboard',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag, Color color) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, '{$tag}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '{$tag}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.copy,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $text'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Helper function to show tags in a dialog
class TemplateTagsDialog {
  static void show(BuildContext context, List<String> availableTags) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 500,
          child: Column(
            children: [
              AppBar(
                title: const Text('Template Tags'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: TemplateTagsDisplay(
                    availableTags: availableTags,
                    showStandardTags: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

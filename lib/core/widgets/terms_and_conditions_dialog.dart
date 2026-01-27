import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  final VoidCallback onAccept;

  const TermsAndConditionsDialog({super.key, required this.onAccept});

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _acceptedTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.description, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSimpleSection(
                        '1. Platform Disclaimer',
                        'This application acts as a platform only. The developer is not responsible for user-generated content, events, or interactions.',
                      ),
                      _buildSimpleSection(
                        '2. User Responsibility',
                        'Users participate at their own risk. You are solely responsible for your interactions with other users and attendance at events.',
                      ),
                      _buildSimpleSection(
                        '3. Event Verification',
                        'The developer does not verify events or users. Please exercise caution and use your best judgment when booking events or interacting with other users.',
                      ),
                      _buildSimpleSection(
                        '4. Content Liability',
                        'All event information, descriptions, and images are provided by event creators. Eventora is not liable for inaccurate, misleading, or inappropriate content.',
                      ),
                      _buildSimpleSection(
                        '5. Payment & Refunds',
                        'All payments are processed through third-party payment gateways. Refund policies are determined by event organizers. Eventora is not responsible for payment disputes or refunds.',
                      ),
                      _buildSimpleSection(
                        '6. Privacy',
                        'By using this app, you agree to our data collection and usage practices. Your personal information will be handled according to our Privacy Policy.',
                      ),
                      _buildSimpleSection(
                        '7. Limitation of Liability',
                        'Eventora, its developers, and affiliates shall not be liable for any direct, indirect, incidental, special, or consequential damages arising from your use of this application.',
                      ),
                      _buildSimpleSection(
                        '8. Changes to Terms',
                        'We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Acceptance Checkbox
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                  const Expanded(
                    child: Text(
                      'I have read and accept the Terms & Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptedTerms
                          ? () {
                              Navigator.of(context).pop(true);
                              widget.onAccept();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

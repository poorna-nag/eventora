import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/core/utils/date_formatter.dart';
import 'package:eventora/features/bookings/data/booking_model.dart';
import 'package:flutter/material.dart';

class ScannerResultScreen extends StatefulWidget {
  final BookingModel booking;
  final String qrData;

  const ScannerResultScreen({
    super.key,
    required this.booking,
    required this.qrData,
  });

  @override
  State<ScannerResultScreen> createState() => _ScannerResultScreenState();
}

class _ScannerResultScreenState extends State<ScannerResultScreen> {
  bool _isCheckingIn = false;

  Future<void> _checkInTicket() async {
    setState(() => _isCheckingIn = true);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.booking.bookingId)
          .update({'isCheckedIn': true, 'checkedInAt': Timestamp.now()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid =
        widget.booking.status == 'confirmed' && !widget.booking.isCheckedIn;
    final isAlreadyCheckedIn = widget.booking.isCheckedIn;
    final isCancelled = widget.booking.status == 'cancelled';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan Result', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isValid
                    ? Colors.green.withOpacity(0.1)
                    : isAlreadyCheckedIn
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isValid
                    ? Icons.check_circle
                    : isAlreadyCheckedIn
                    ? Icons.verified
                    : Icons.cancel,
                size: 60,
                color: isValid
                    ? Colors.green
                    : isAlreadyCheckedIn
                    ? Colors.blue
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 24),

            // Status Text
            Text(
              isValid
                  ? 'Valid Ticket'
                  : isAlreadyCheckedIn
                  ? 'Already Checked In'
                  : isCancelled
                  ? 'Cancelled Ticket'
                  : 'Invalid Ticket',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isValid
                    ? Colors.green
                    : isAlreadyCheckedIn
                    ? Colors.blue
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 40),

            // Ticket Details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    Icons.event,
                    'Event',
                    widget.booking.eventTitle ?? 'Unknown',
                  ),
                  const SizedBox(height: 16),
                  if (widget.booking.eventDate != null)
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Date',
                      DateFormatter.formatDate(widget.booking.eventDate!),
                    ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.confirmation_number,
                    'Tickets',
                    '${widget.booking.slotsBooked} Person${widget.booking.slotsBooked > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.payment,
                    'Amount Paid',
                    '₹${widget.booking.amountPaid}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.receipt,
                    'Booking ID',
                    widget.booking.bookingId.substring(0, 8).toUpperCase(),
                  ),
                  if (isAlreadyCheckedIn &&
                      widget.booking.checkedInAt != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.access_time,
                      'Checked In At',
                      DateFormatter.formatDate(
                        widget.booking.checkedInAt!.toDate(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Check-in Button
            if (isValid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCheckingIn ? null : _checkInTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCheckingIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Check In Ticket',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

            // Close Button
            if (!isValid)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

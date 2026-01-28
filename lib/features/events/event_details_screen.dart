import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/utils/date_formatter.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/core/widgets/phone_verification_dialog.dart';
import 'package:eventora/core/services/phone_verification_service.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/bookings/bloc/booking_bloc.dart';
import 'package:eventora/features/bookings/bloc/booking_event.dart';
import 'package:eventora/features/bookings/bloc/booking_state.dart';
import 'package:eventora/features/bookings/data/booking_model.dart';
import 'package:eventora/features/bookings/booking_success_screen.dart';
import 'package:eventora/features/bookings/ticket_qr_screen.dart';
import 'package:eventora/features/events/data/event_model.dart';
import 'package:eventora/features/moderation/data/moderation_service.dart';
import 'package:eventora/features/moderation/presentation/report_dialog.dart';
import 'package:eventora/core/services/payment_service.dart';
import 'package:eventora/features/join_requests/data/join_request_model.dart';
import 'package:eventora/features/join_requests/data/join_request_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/join_requests/presentation/join_requests_screen.dart';
import 'package:eventora/features/auth/data/user_model.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/profile/presentation/public_profile_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;
  final BookingModel? existingBooking;

  const EventDetailsScreen({
    super.key,
    required this.event,
    this.existingBooking,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _selectedPersons = 1;
  final PaymentService _paymentService = PaymentService();
  final ModerationService _moderationService = ModerationService();
  final JoinRequestRepository _joinRequestRepository = JoinRequestRepository();

  final AuthRepository _authRepository = AuthRepository();
  JoinRequestModel? _userJoinRequest;
  UserModel? _host;

  @override
  void initState() {
    super.initState();
    _paymentService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
    _checkJoinRequest();
    _fetchHostDetails();
  }

  Future<void> _fetchHostDetails() async {
    try {
      final host = await _authRepository.getUserData(widget.event.createdBy);
      if (mounted) {
        setState(() {
          _host = host;
        });
      }
    } catch (e) {
      print('Error fetching host details: $e');
    }
  }

  Future<void> _checkJoinRequest() async {
    if (!widget.event.isPrivate) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    try {
      final request = await _joinRequestRepository.getUserRequestForEvent(
        authState.user.uid,
        widget.event.eventId,
      );
      if (mounted) {
        setState(() {
          _userJoinRequest = request;
        });
      }
    } catch (e) {
      print('Error checking join request: $e');
    }
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final double totalAmount = (widget.event.price * _selectedPersons)
        .toDouble();

    context.read<BookingBloc>().add(
      BookingCreateRequested(
        eventId: widget.event.eventId,
        userId: authState.user.uid,
        slotsBooked: _selectedPersons,
        totalAmount: totalAmount,
        paymentId: response.paymentId ?? 'unknown_payment_id',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleBooking() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.loginToBook)));
      return;
    }

    if (authState.user.uid == widget.event.createdBy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.cannotBookOwnEvent)),
      );
      return;
    }

    if (widget.event.availableSlots < _selectedPersons) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.notEnoughSlots)));
      return;
    }

    // Check if phone is verified
    final phoneVerificationService = PhoneVerificationService();
    final isVerified = await phoneVerificationService.isPhoneVerified(
      authState.user.uid,
    );

    if (!isVerified) {
      // Show phone verification dialog
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PhoneVerificationDialog(
            userId: authState.user.uid,
            onVerified: (phoneNumber) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number verified successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Continue with booking after verification
              _proceedWithBooking();
            },
          ),
        );
      }
      return;
    }

    // If already verified, proceed with booking
    _proceedWithBooking();
  }

  void _proceedWithBooking() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Skip payment for free events
    if (widget.event.price == 0) {
      context.read<BookingBloc>().add(
        BookingCreateRequested(
          eventId: widget.event.eventId,
          userId: authState.user.uid,
          slotsBooked: _selectedPersons,
          totalAmount: 0,
          paymentId: 'free_event_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return;
    }

    _paymentService.openCheckout(
      amount: (widget.event.price * _selectedPersons).toDouble(),
      name: 'Eventora Booking',
      description: 'Booking for ${widget.event.title}',
      contact:
          authState.user.phoneNumber ??
          '', // You might want to get this from user profile if available
      email: authState.user.email ?? '',
    );
  }

  Future<void> _handleJoinRequest() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginToRequestJoin)),
      );
      return;
    }

    if (authState.user.uid == widget.event.createdBy) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.hostOfEvent)));
      return;
    }

    try {
      final request = JoinRequestModel(
        requestId: '',
        eventId: widget.event.eventId,
        userId: authState.user.uid,
        userName: authState.user.name,
        userProfileImage: authState.user.profileImageUrl,
        eventTitle: widget.event.title,
        hostId: widget.event.createdBy,
        slotsRequested: _selectedPersons,
        requestedAt: Timestamp.now(),
        eventPrice: widget.event.price,
      );

      await _joinRequestRepository.createJoinRequest(request);
      await _checkJoinRequest(); // Refresh the request status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.joinRequestSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.joinRequestFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareEvent() {
    final String shareText =
        '''
🎉 Check out this amazing event!

${widget.event.title}

📅 ${DateFormatter.formatDate(widget.event.date)}
⏰ ${DateFormatter.formatTime(widget.event.time)}
📍 ${widget.event.venue}
💰 ${widget.event.price == 0 ? 'Free Entry' : '₹${widget.event.price} per person'}

${widget.event.description}

Book now on Eventora! 🎫
''';

    Share.share(shareText, subject: 'Event: ${widget.event.title}');
  }

  void _inviteFriends() {
    final String inviteText =
        '''
Hey! 👋

I'm going to this event and thought you might be interested:

🎉 ${widget.event.title}

📅 ${DateFormatter.formatDate(widget.event.date)}
⏰ ${DateFormatter.formatTime(widget.event.time)}
📍 ${widget.event.venue}
💰 ${widget.event.price == 0 ? 'Free Entry!' : '₹${widget.event.price} per person'}

Let's go together! Download Eventora and book your tickets now! 🎫

See you there! 🙌
''';

    Share.share(inviteText, subject: 'Join me at ${widget.event.title}!');
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        reportedUserId: widget.event.createdBy,
        reportedEventId: widget.event.eventId,
        reportType: 'event',
      ),
    );
  }

  Future<void> _blockEventCreator() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.block),
        content: const Text(AppStrings.blockUserConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              AppStrings.block,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _moderationService.blockUser(
          blockerId: authState.user.uid,
          blockedUserId: widget.event.createdBy,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.userBlockedSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.userBlockFailed}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          // Navigate to success screen

          // Navigate to success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingSuccessScreen(
                event: widget.event,
                ticketsBooked: _selectedPersons,
                totalAmount: widget.event.price * _selectedPersons,
              ),
            ),
          );
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final authState = context.read<AuthBloc>().state;
    final isHost =
        authState is AuthAuthenticated &&
        authState.user.uid == widget.event.createdBy;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              if (isHost && widget.event.isPrivate)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JoinRequestsScreen(
                          eventId: widget.event.eventId,
                          eventTitle: widget.event.title,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Join Requests',
                ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareEvent,
                tooltip: 'Share Event',
              ),
              IconButton(
                icon: const Icon(Icons.person_add, color: Colors.white),
                onPressed: _inviteFriends,
                tooltip: 'Invite Friends',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportDialog();
                  } else if (value == 'block') {
                    _blockEventCreator();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Report Event'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text('Block User'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl == AppStrings.defaultEventImage
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            bottom: -30,
                            child: Icon(
                              Icons.event,
                              size: 200,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                widget.event.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.event, size: 80),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.event.availableSlots}/${widget.event.totalSlots}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: widget.event.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (widget.existingBooking != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Your Existing Booking',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.existingBooking!.slotsBooked} Ticket${widget.existingBooking!.slotsBooked > 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Paid: ₹${widget.existingBooking!.amountPaid}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      widget.existingBooking!.status ==
                                          'confirmed'
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.existingBooking!.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Text(
                            'Want to book more tickets? Select below!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketQRScreen(
                                booking: widget.existingBooking!,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code, color: Colors.white),
                        label: const Text(
                          'View Ticket QR',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormatter.formatDate(widget.event.date),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    DateFormatter.formatTime(widget.event.time),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on,
                    'Venue',
                    widget.event.address ?? widget.event.venue,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Price',
                    widget.event.price == 0
                        ? 'Free'
                        : '₹${widget.event.price} per person',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_host != null) ...[
                    const Text(
                      'Hosted By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (_host != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicProfileScreen(
                                userId: widget.event.createdBy,
                                user: _host,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _host!.profileImageUrl != null
                                  ? CachedNetworkImageProvider(
                                      _host!.profileImageUrl!,
                                    )
                                  : null,
                              child: _host!.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.grey.shade400,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _host!.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_host!.workplace != null &&
                                      _host!.workplace!.isNotEmpty)
                                    Text(
                                      _host!.workplace!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareEvent,
                          icon: const Icon(Icons.share, size: 20),
                          label: const Text('Share Event'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _inviteFriends,
                          icon: const Icon(
                            Icons.person_add,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Invite Friends',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.event.availableSlots > 0 && !isHost) ...[
                    const Text(
                      'Number of Persons',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _selectedPersons > 1
                              ? () => setState(() => _selectedPersons--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.orange,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_selectedPersons',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _selectedPersons < widget.event.availableSlots
                              ? () => setState(() => _selectedPersons++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.orange,
                        ),
                        const Spacer(),
                        Text(
                          'Total: ₹${widget.event.price * _selectedPersons}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final isBooking = state is BookingCreating;

          // Hide booking/request option for host
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated &&
              authState.user.uid == widget.event.createdBy) {
            return const SizedBox.shrink();
          }

          // For private events, show join request button
          if (widget.event.isPrivate) {
            if (_userJoinRequest == null) {
              // No request yet - show "Request to Join" button
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: 'Request to Join',
                  onPressed: _handleJoinRequest,
                  icon: Icons.lock_open,
                ),
              );
            } else if (_userJoinRequest!.status == 'pending') {
              // Request pending
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: 'Request Pending',
                  onPressed: null,
                  backgroundColor: Colors.orange,
                  icon: Icons.pending,
                ),
              );
            } else if (_userJoinRequest!.status == 'accepted') {
              // Request accepted - show book now button
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: 'Book Now',
                  onPressed: _handleBooking,
                  isLoading: isBooking,
                ),
              );
            } else {
              // Request rejected
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: 'Request Rejected',
                  onPressed: null,
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          // For public events, show normal booking button
          return widget.event.availableSlots > 0
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: 'Book Now',
                    onPressed: _handleBooking,
                    isLoading: isBooking,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    text: 'Sold Out',
                    onPressed: null,
                    backgroundColor: Colors.grey,
                  ),
                );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

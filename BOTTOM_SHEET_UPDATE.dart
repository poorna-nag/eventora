// // MANUAL UPDATE NEEDED FOR event_details_screen.dart
// // Replace the bottomSheet property (around line 794-836) with this code:

// bottomSheet: BlocBuilder<BookingBloc, BookingState>(
//   builder: (context, state) {
//     final isBooking = state is BookingCreating;

//     // For private events, show join request button
//     if (widget.event.isPrivate) {
//       if (_userJoinRequest == null) {
//         // No request yet - show "Request to Join" button
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: CustomButton(
//             text: 'Request to Join',
//             onPressed: _handleJoinRequest,
//             icon: Icons.lock_open,
//           ),
//         );
//       } else if (_userJoinRequest!.status == 'pending') {
//         // Request pending
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: CustomButton(
//             text: 'Request Pending',
//             onPressed: null,
//             backgroundColor: Colors.orange,
//             icon: Icons.pending,
//           ),
//         );
//       } else if (_userJoinRequest!.status == 'accepted') {
//         // Request accepted - show book now button
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: CustomButton(
//             text: 'Book Now',
//             onPressed: _handleBooking,
//             isLoading: isBooking,
//           ),
//         );
//       } else {
//         // Request rejected
//         return Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5),
//               ),
//             ],
//           ),
//           child: CustomButton(
//             text: 'Request Rejected',
//             onPressed: null,
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }

//     // For public events, show normal booking button
//     return widget.event.availableSlots > 0
//         ? Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: CustomButton(
//               text: 'Book Now',
//               onPressed: _handleBooking,
//               isLoading: isBooking,
//             ),
//           )
//         : Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: CustomButton(
//               text: 'Sold Out',
//               onPressed: null,
//               backgroundColor: Colors.grey,
//             ),
//           );
//   },
// ),

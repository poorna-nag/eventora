# Private/Public Event Feature Implementation Summary

## ✅ Completed Changes

### 1. Event Model Updated
- Added `isPrivate` boolean field to `EventModel`
- Updated all JSON serialization methods
- Default value is `false` (public events)

### 2. Join Request System Created
- **JoinRequestModel** (`lib/features/join_requests/data/join_request_model.dart`)
  - Tracks join requests for private events
  - Includes user info, event details, status, and payment tracking
  
- **JoinRequestRepository** (`lib/features/join_requests/data/join_request_repository.dart`)
  - CRUD operations for join requests
  - Accept/reject functionality
  - Payment tracking

- **JoinRequestsScreen** (`lib/features/join_requests/presentation/join_requests_screen.dart`)
  - Screen for hosts to view and manage join requests
  - Accept/reject buttons
  - Status tracking (pending/accepted/rejected)

### 3. Create Event Screen Updated
- Added Private/Public toggle button above image selector
- Made price field optional (shows "Price (₹) - Optional")
- Events with empty price default to 0 (free events)
- Toggle uses orange color for selected state

### 4. Event Details Screen - Partially Updated
- Added join request repository and state tracking
- Added `_handleJoinRequest()` method
- Added `_checkJoinRequest()` method to check existing requests

## ⚠️ REMAINING WORK

### Event Details Screen Bottom Sheet
The bottom sheet in `event_details_screen.dart` needs to be updated to show different buttons based on event type and request status.

**Location:** Lines 794-836 in `event_details_screen.dart`

**Replace the entire bottomSheet widget with:**

```dart
bottomSheet: BlocBuilder<BookingBloc, BookingState>(
  builder: (context, state) {
    final isBooking = state is BookingCreating;

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
```

### How to Integrate Join Requests Screen

Event hosts need a way to access the join requests screen. You can add this in:

1. **Event Preview Screen** - Add a "View Join Requests" button for private events
2. **My Created Events Screen** - Add a button next to each private event
3. **Profile Screen** - Add a "Pending Requests" section

Example button to add:
```dart
if (event.isPrivate) {
  ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinRequestsScreen(
            eventId: event.eventId,
            eventTitle: event.title,
          ),
        ),
      );
    },
    icon: const Icon(Icons.pending_actions),
    label: const Text('View Join Requests'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    ),
  ),
}
```

## How It Works

### For Public Events (isPrivate = false):
1. Users see the event
2. Click "Book Now"
3. Complete payment (if paid) or book directly (if free)
4. Get confirmation

### For Private Events (isPrivate = true):
1. Users see the event
2. Click "Request to Join"
3. Request is sent to host
4. Button changes to "Request Pending"
5. Host reviews request in Join Requests Screen
6. If accepted:
   - User gets notification (to be implemented)
   - Button changes to "Book Now"
   - User can complete booking (with payment if needed)
7. If rejected:
   - Button shows "Request Rejected"

## Firebase Security Rules Needed

Add to Firestore rules:
```
match /join_requests/{requestId} {
  allow read: if request.auth != null && 
    (request.auth.uid == resource.data.userId || 
     request.auth.uid == resource.data.hostId);
  allow create: if request.auth != null && 
    request.auth.uid == request.resource.data.userId;
  allow update: if request.auth != null && 
    request.auth.uid == resource.data.hostId;
  allow delete: if request.auth != null && 
    (request.auth.uid == resource.data.userId || 
     request.auth.uid == resource.data.hostId);
}
```

## Testing Checklist

- [ ] Create a public event - should work as before
- [ ] Create a private event - toggle should show
- [ ] Create a free event (empty price) - should default to ₹0
- [ ] View private event as non-host - should show "Request to Join"
- [ ] Send join request - should change to "Request Pending"
- [ ] Host views join requests - should see pending requests
- [ ] Host accepts request - user should see "Book Now"
- [ ] Host rejects request - user should see "Request Rejected"
- [ ] Complete booking after acceptance - should work normally

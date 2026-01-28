class AppStrings {
  // Auth Strings
  static const String appName = 'Eventora';
  static const String welcomeBack = 'Welcome Back!';
  static const String loginSubtitle = 'Please login to continue';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String registerNow = 'Register Now';
  static const String createAccount = 'Create Account';
  static const String signupSubtitle = 'Sign up to start hosting events';
  static const String name = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String or = 'OR';

  // Forgot Password
  static const String forgotPasswordTitle = "Forgot Password?";
  static const String forgotPasswordSubtitle =
      "Don't worry! Enter your email and we'll send you a reset link";
  static const String sendResetLink = 'Send Reset Link';
  static const String resetPassword = 'Reset Password';
  static const String emailSent = 'Email Sent!';
  static const String emailSentSubtitle = "We've sent a password reset link to";
  static const String backToLogin = 'Back to Login';

  // Warnings / Dialogs
  static const String acceptTermsWarning =
      'You must accept the Terms & Conditions to use this app';
  static const String termsTitle = 'Terms & Conditions';
  static const String safetyWarningTitle = 'Safety Warning';
  static const String ageVerificationTitle = 'Age Verification';
  static const String ageVerificationSubtitle =
      'Please verify your age to continue';

  // Validation Strings
  static const String emailRequired = 'Email is required';
  static const String validEmailRequired = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength =
      'Password must be at least 6 characters';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String fieldRequired = 'is required';
  static const String validNumberRequired = 'Please enter a valid number';
  static const String positiveNumberRequired = 'must be greater than 0';

  // Error Strings
  static const String unknownError = 'An unexpected error occurred';
  static const String userNotFound = 'No user found for that email';
  static const String weakPassword = 'The password provided is too weak';
  static const String emailInUse = 'An account already exists for that email';
  static const String wrongPassword = 'Wrong password provided';
  static const String invalidEmail = 'Invalid email address';
  static const String userDisabled = 'This user has been disabled';
  static const String tooManyRequests =
      'Too many requests. Please try again later';
  static const String sessionExpired = 'Session expired. Please try again';
  static const String appNameWithAge = 'EventorA¹⁸⁺';
  static const String appTagline = 'Where Strangers Meet & Stories Begin';
  static const String ageVerificationQuestion =
      'Are you 18 years of age or older?';
  static const String ageWarning =
      'This app contains content suitable only for adults.';
  static const String yesOver18 = 'Yes, I am 18+';
  static const String noUnder18 = 'No, I am under 18';
  static const String underAgeError = 'You must be 18+ to use this app.';
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String scanTicket = 'Scan Ticket';
  static const String bio = 'Bio';
  static const String workplace = 'Workplace';
  static const String interests = 'Interests';
  static const String eventsCreated = 'Events Created';
  static const String bookingsMade = 'Bookings Made';
  static const String inviteFriends = 'Invite Friends';
  static const String inviteFriendsSubtitle =
      'Share Eventora with your friends';
  static const String logout = 'Logout';
  static const String logoutConfirm =
      'Are you sure you want to logout?\nYou can always come back!';
  static const String cancel = 'Cancel';
  static const String profileUpdated = 'Profile picture updated!';
  static const String failedToShare = 'Failed to share';

  static const String inviteFriendMessage = '''
🎉 Join me on Eventora! 🎉

Discover and book amazing events near you!

✨ Features:
• Browse local events
• Book tickets instantly
• QR code ticket system
• Create your own events
• Secure payments

Download Eventora now and never miss an event!

📱 Get the app: [Link]
''';
  static const String inviteSubject =
      'Join me on Eventora - Discover Amazing Events!';
  static const String save = 'Save';
  static const String profileUpdatedSuccess = 'Profile updated successfully';
  static const String profileUpdateFailed = 'Failed to update profile';
  static const String bioHint = 'Tell us about yourself...';
  static const String workplaceHint = 'Where do you work?';
  static const String socialHint = '@username';
  static const String searchEvents = 'Search events...';
  static const String gettingLocation = 'Getting location...';
  static const String currentLocation = 'Current location';
  static const String noEventsFound = 'No events found';
  static const String loadingEvents = 'Loading events...';
  static const String filterEvents = 'Filter Events';
  static const String clearAll = 'Clear All';
  static const String categoriesSelection = 'Categories (Multiple Selection)';
  static const String priceRange = 'Price Range';
  static const String minPrice = 'Min Price';
  static const String maxPrice = 'Max Price';
  static const String dateRange = 'Date Range';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String applyFilters = 'Apply Filters';
  static const String retry = 'Retry';
  static const String locationFetchFailed = 'Failed to get location';

  // Permission Strings
  static const String permissionsTitle = 'App Permissions';
  static const String permissionsSubtitle =
      'To provide the best experience, Eventora needs a few permissions';
  static const String allowAll = 'Allow All Permissions';
  static const String locationPermission = 'Location';
  static const String locationPermissionDesc =
      'To find and show events near you';
  static const String cameraPermission = 'Camera';
  static const String cameraPermissionDesc =
      'To scan QR tickets and capture profile photos';
  static const String storagePermission = 'Photos & Storage';
  static const String storagePermissionDesc =
      'To upload profile pictures and save tickets';
  static const String continueText = 'Continue';

  // Event Details Strings
  static const String cannotBookOwnEvent = 'You cannot book your own event';
  static const String hostOfEvent = 'You are the host of this event';
  static const String loginToBook = 'Please login to book events';
  static const String loginToRequestJoin = 'Please login to request join';
  static const String notEnoughSlots = 'Not enough slots available';
  static const String joinRequestSent =
      'Join request sent! Wait for host approval.';
  static const String joinRequestFailed = 'Failed to send request';
  static const String userBlockedSuccess = 'User blocked successfully';
  static const String userBlockFailed = 'Failed to block user';
  static const String blockUserConfirm =
      'Are you sure you want to block this user? You will no longer see their events.';
  static const String block = 'Block';
  static const String defaultEventImage = 'TEXT_ONLY';
  static const String defaultVenue = 'Venue to be announced';
}

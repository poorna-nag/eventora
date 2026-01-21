import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/core/services/firebase_storage_service.dart';
import 'package:eventora/core/services/location_service.dart';
import 'package:eventora/core/utils/validators.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/core/widgets/custom_text_field.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/create/presentation/party_category_grid.dart';
import 'package:eventora/features/events/bloc/event_bloc.dart';
import 'package:eventora/features/events/bloc/event_event.dart';
import 'package:eventora/features/events/bloc/event_state.dart';
import 'package:eventora/features/events/data/event_model.dart';
import 'package:eventora/features/events/event_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController();
  final _personsController = TextEditingController();

  final FirebaseStorageService _storageService = FirebaseStorageService();
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  File? _selectedImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _selectedCategories = [];
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _personsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _getVenueLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _venueController.text = address;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location set: $address'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to get location: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event image')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select event date')));
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select event time')));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to create events')),
      );
      return;
    }

    try {
      String imageUrl;
      try {
        imageUrl = await _storageService.uploadEventImage(_selectedImage!);
      } catch (uploadError) {
        print('Image upload failed: $uploadError');
        // Use a placeholder image URL if upload fails
        // This allows event creation to proceed despite storage issues
        imageUrl = 'https://via.placeholder.com/400x300.png?text=Event+Image';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image upload failed. Using placeholder. Please check Firebase Storage rules.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }

      final eventTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final event = EventModel(
        eventId: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        time: eventTime,
        venue: _venueController.text.trim(),
        price: int.parse(_priceController.text),
        totalSlots: int.parse(_personsController.text),
        availableSlots: int.parse(_personsController.text),
        createdBy: authState.user.uid,
        imageUrl: imageUrl,
        categories: _selectedCategories.isNotEmpty
            ? _selectedCategories
            : ['Other'],
        createdAt: Timestamp.now(),
      );

      context.read<EventBloc>().add(EventCreateRequested(event: event));
      await _authRepository.incrementEventsCreated(authState.user.uid);
      // Refresh auth state so profile stats (eventsCreated) update
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventCreated) {
          // Navigate to preview screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventPreviewScreen(event: state.event),
            ),
          );

          // Reset form
          _formKey.currentState!.reset();
          setState(() {
            _selectedImage = null;
            _selectedDate = null;
            _selectedTime = null;
            _selectedCategories = [];
          });
          _titleController.clear();
          _descriptionController.clear();
          _venueController.clear();
          _priceController.clear();
          _personsController.clear();
        } else if (state is EventError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Create Event',
            style: TextStyle(color: Colors.orange),
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<EventBloc, EventState>(
          builder: (context, state) {
            final isCreating = state is EventCreating;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    size: 60,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to upload event image',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _titleController,
                      hintText: 'Event Title',
                      validator: (value) =>
                          Validators.validateRequired(value, 'Title'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Event Description',
                      maxLines: 4,
                      validator: (value) =>
                          Validators.validateRequired(value, 'Description'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Categories ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PartyCategoryGrid(
                      onCategoriesChanged: (categories) {
                        setState(() {
                          _selectedCategories = categories;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _venueController,
                      hintText: 'Venue / Address',
                      validator: (value) =>
                          Validators.validateRequired(value, 'Venue'),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                      ),
                      suffixIcon: _isLoadingLocation
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.my_location,
                                color: Colors.orange,
                              ),
                              tooltip: 'Use current location',
                              onPressed: _getVenueLocation,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text: _selectedDate != null
                                  ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_selectedDate!)
                                  : '',
                            ),
                            hintText: 'Select Date',
                            readOnly: true,
                            onTap: _selectDate,
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text: _selectedTime != null
                                  ? _selectedTime!.format(context)
                                  : '',
                            ),
                            hintText: 'Select Time',
                            readOnly: true,
                            onTap: _selectTime,
                            prefixIcon: const Icon(
                              Icons.access_time,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            hintText: 'Price (₹)',
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                Validators.validateNumber(value, 'Price'),
                            prefixIcon: const Icon(
                              Icons.currency_rupee,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _personsController,
                            hintText: 'Total Persons',
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                Validators.validatePositiveNumber(
                                  value,
                                  'Persons',
                                ),
                            prefixIcon: const Icon(
                              Icons.people,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Create Event',
                      onPressed: _createEvent,
                      isLoading: isCreating,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

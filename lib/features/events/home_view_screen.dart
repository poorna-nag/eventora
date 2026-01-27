import 'package:eventora/core/services/location_service.dart';
import 'package:eventora/core/widgets/event_card.dart';
import 'package:eventora/features/events/bloc/event_bloc.dart';
import 'package:eventora/features/events/bloc/event_event.dart';
import 'package:eventora/features/events/bloc/event_state.dart';
import 'package:eventora/features/events/event_details_screen.dart';
import 'package:eventora/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeViewScreen extends StatefulWidget {
  const HomeViewScreen({super.key});

  @override
  State<HomeViewScreen> createState() => _HomeViewScreenState();
}

class _HomeViewScreenState extends State<HomeViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final LocationService _locationService = LocationService();

  List<String> _selectedCategories = [];
  int? _minPrice;
  int? _maxPrice;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  final List<String> _categories = [
    'Music',
    'Sports',
    'Tech',
    'Food',
    'Art',
    'Business',
    'Party',
    'DJ',
    'Dance',
    'Games',
    'Live',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      print('Requesting location...');
      final position = await _locationService.getCurrentLocation();
      print('Got position: ${position?.latitude}, ${position?.longitude}');

      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        print('Got address: $address');
        if (mounted) {
          setState(() {
            _currentAddress = address;
          });
        }
      }
    } catch (e) {
      print('Location error: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Unable to get location';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to get location: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getCurrentLocation,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Eventora¹⁸⁺',
                    style: GoogleFonts.aboreto(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),

                  const Spacer(),
                  // Notification Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar and Location
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Current Location Button - Full width, left aligned, no border
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _isLoadingLocation
                                  ? 'Getting location...'
                                  : _currentAddress ?? 'Current location',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isLoadingLocation) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Field with Round Button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            context.read<EventBloc>().add(
                              EventSearchChanged(query: value),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 22,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Round Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _showFilterDialog,
                          tooltip: 'Filter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Events List
            Expanded(
              child: BlocBuilder<EventBloc, EventState>(
                builder: (context, state) {
                  if (state is EventLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EventError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is EventLoaded) {
                    final events = state.filteredEvents;

                    if (events.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<EventBloc>().add(EventLoadRequested());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCard(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsScreen(event: event),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading events...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    // Create temporary variables for dialog state
    List<String> tempCategories = List.from(_selectedCategories);
    int? tempMinPrice = _minPrice;
    int? tempMaxPrice = _maxPrice;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Text('Filter Events'),
                  const Spacer(),
                  if (tempCategories.isNotEmpty ||
                      tempMinPrice != null ||
                      tempMaxPrice != null ||
                      tempStartDate != null)
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempCategories.clear();
                          tempMinPrice = null;
                          tempMaxPrice = null;
                          tempStartDate = null;
                          tempEndDate = null;
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Section
                    const Text(
                      'Categories (Multiple Selection)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSelected = tempCategories.contains(category);
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                tempCategories.remove(category);
                              } else {
                                tempCategories.add(category);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B5BD6)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Price Range Section
                    const Text(
                      'Price Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Min Price',
                              prefixText: '₹',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            controller: TextEditingController(
                              text: tempMinPrice?.toString() ?? '',
                            ),
                            onChanged: (value) {
                              tempMinPrice = int.tryParse(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Max Price',
                              prefixText: '₹',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            controller: TextEditingController(
                              text: tempMaxPrice?.toString() ?? '',
                            ),
                            onChanged: (value) {
                              tempMaxPrice = int.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date Range Section
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  tempStartDate = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              tempStartDate != null
                                  ? DateFormat('MMM dd').format(tempStartDate!)
                                  : 'Start Date',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    tempEndDate ??
                                    tempStartDate ??
                                    DateTime.now(),
                                firstDate: tempStartDate ?? DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  tempEndDate = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                              tempEndDate != null
                                  ? DateFormat('MMM dd').format(tempEndDate!)
                                  : 'End Date',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories = tempCategories;
                      _minPrice = tempMinPrice;
                      _maxPrice = tempMaxPrice;
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });

                    // Apply filters (simplified - you'll need to update EventBloc to handle multiple categories)
                    context.read<EventBloc>().add(
                      EventFilterChanged(
                        category: tempCategories.isNotEmpty
                            ? tempCategories.first
                            : null,
                        maxPrice: tempMaxPrice,
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B5BD6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

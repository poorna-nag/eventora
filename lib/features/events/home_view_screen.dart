import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventora/core/services/location_service.dart';
import 'package:eventora/core/widgets/event_card.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/events/bloc/event_bloc.dart';
import 'package:eventora/features/events/bloc/event_event.dart';
import 'package:eventora/features/events/bloc/event_state.dart';
import 'package:eventora/features/events/event_details_screen.dart';
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location: $address'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
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
      // backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Eventora',
                    style: GoogleFonts.aboreto(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),

                  const Spacer(),
                  // Profile Picture
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to profile
                            DefaultTabController.of(context).animateTo(3);
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: state.user.profileImageUrl != null
                                ? CachedNetworkImageProvider(
                                    state.user.profileImageUrl!,
                                  )
                                : null,
                            child: state.user.profileImageUrl == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                        );
                      }
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // Filter Button with Badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: GestureDetector(
                          onTap: _showFilterDialog,
                          child: Row(
                            children: [
                              Icon(
                                Icons.tune,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      if (_selectedCategories.isNotEmpty ||
                          _minPrice != null ||
                          _maxPrice != null ||
                          _startDate != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${_selectedCategories.length + (_minPrice != null ? 1 : 0) + (_maxPrice != null ? 1 : 0) + (_startDate != null ? 1 : 0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
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
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<EventBloc>().add(
                        EventSearchChanged(query: value),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Current Location Button
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B5BD6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isLoadingLocation
                                  ? 'Getting location...'
                                  : _currentAddress ?? 'Get current location',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isLoadingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
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

import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
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
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() => _currentAddress = address);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = AppStrings.locationFetchFailed);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.locationFetchFailed}: $e'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: AppStrings.retry,
              textColor: Colors.white,
              onPressed: _getCurrentLocation,
            ),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndLocation(),
            _buildEventsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            AppStrings.appNameWithAge,
            style: GoogleFonts.aboreto(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.iconColor,
            ),
          ),
          const Spacer(),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.iconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildSearchAndLocation() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          _buildLocationButton(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSearchField()),
              const SizedBox(width: 12),
              _buildFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.iconColor, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _isLoadingLocation
                    ? AppStrings.gettingLocation
                    : _currentAddress ?? AppStrings.currentLocation,
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
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.iconColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) =>
          context.read<EventBloc>().add(EventSearchChanged(query: value)),
      decoration: InputDecoration(
        hintText: AppStrings.searchEvents,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.iconColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.iconColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.iconColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.tune, color: Colors.white, size: 22),
        onPressed: _showFilterDialog,
        tooltip: 'Filter',
      ),
    );
  }

  Widget _buildEventsList() {
    return Expanded(
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
            if (events.isEmpty) return _buildEmptyState();
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<EventBloc>().add(EventLoadRequested()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(
                    event: event,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(event: event),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  AppStrings.loadingEvents,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppStrings.noEventsFound,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
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
                  const Text(AppStrings.filterEvents),
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
                      child: const Text(AppStrings.clearAll),
                    ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.categoriesSelection,
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
                              isSelected
                                  ? tempCategories.remove(category)
                                  : tempCategories.add(category);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.priceRange,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildPriceField(
                          AppStrings.minPrice,
                          tempMinPrice,
                          (v) => tempMinPrice = int.tryParse(v),
                        ),
                        const SizedBox(width: 12),
                        _buildPriceField(
                          AppStrings.maxPrice,
                          tempMaxPrice,
                          (v) => tempMaxPrice = int.tryParse(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.dateRange,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateRangeRow(tempStartDate, tempEndDate, (
                      start,
                      end,
                    ) {
                      setDialogState(() {
                        tempStartDate = start;
                        tempEndDate = end;
                      });
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(AppStrings.cancel),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(AppStrings.applyFilters),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPriceField(
    String label,
    int? value,
    Function(String) onChanged,
  ) {
    return Expanded(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '₹',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateRangeRow(
    DateTime? start,
    DateTime? end,
    Function(DateTime?, DateTime?) onUpdate,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: start ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) onUpdate(date, end);
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              start != null
                  ? DateFormat('MMM dd').format(start)
                  : AppStrings.startDate,
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
                initialDate: end ?? start ?? DateTime.now(),
                firstDate: start ?? DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) onUpdate(start, date);
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              end != null
                  ? DateFormat('MMM dd').format(end)
                  : AppStrings.endDate,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:eventora/features/events/data/event_model.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventModel> events;
  final String? searchQuery;
  final String? categoryFilter;
  final int? maxPriceFilter;

  const EventLoaded({
    required this.events,
    this.searchQuery,
    this.categoryFilter,
    this.maxPriceFilter,
  });

  List<EventModel> get filteredEvents {
    var filtered = events;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      filtered = filtered.where((event) {
        final query = searchQuery!.toLowerCase();
        return event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.venue.toLowerCase().contains(query);
      }).toList();
    }

    if (categoryFilter != null) {
      filtered = filtered.where((event) => event.category == categoryFilter).toList();
    }

    if (maxPriceFilter != null) {
      filtered = filtered.where((event) => event.price <= maxPriceFilter!).toList();
    }

    return filtered;
  }

  @override
  List<Object?> get props => [events, searchQuery, categoryFilter, maxPriceFilter];
}

class EventCreating extends EventState {}

class EventCreated extends EventState {}

class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}

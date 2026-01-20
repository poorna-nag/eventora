import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/events/bloc/event_event.dart';
import 'package:eventora/features/events/bloc/event_state.dart';
import 'package:eventora/features/events/data/event_repository.dart';
import 'package:eventora/features/events/data/event_model.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository;

  EventBloc({required this.eventRepository}) : super(EventInitial()) {
    on<EventLoadRequested>(_onEventLoadRequested);
    on<EventCreateRequested>(_onEventCreateRequested);
    on<EventFilterChanged>(_onEventFilterChanged);
    on<EventSearchChanged>(_onEventSearchChanged);
  }

  Future<void> _onEventLoadRequested(
    EventLoadRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());

    await emit.forEach<List<EventModel>>(
      eventRepository.getEventsStream(),
      onData: (events) => EventLoaded(events: events),
      onError: (error, stackTrace) => EventError(message: error.toString()),
    );
  }

  Future<void> _onEventCreateRequested(
    EventCreateRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventCreating());

    try {
      final eventId = await eventRepository.createEvent(event.event);
      final createdEvent = event.event.copyWith(eventId: eventId);
      emit(EventCreated(event: createdEvent));
    } catch (e) {
      emit(EventError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onEventFilterChanged(
    EventFilterChanged event,
    Emitter<EventState> emit,
  ) async {
    if (state is EventLoaded) {
      final currentState = state as EventLoaded;
      emit(
        EventLoaded(
          events: currentState.events,
          searchQuery: currentState.searchQuery,
          categoryFilter: event.category,
          maxPriceFilter: event.maxPrice,
        ),
      );
    }
  }

  Future<void> _onEventSearchChanged(
    EventSearchChanged event,
    Emitter<EventState> emit,
  ) async {
    if (state is EventLoaded) {
      final currentState = state as EventLoaded;
      emit(
        EventLoaded(
          events: currentState.events,
          searchQuery: event.query,
          categoryFilter: currentState.categoryFilter,
          maxPriceFilter: currentState.maxPriceFilter,
        ),
      );
    }
  }
}

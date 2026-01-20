import 'package:equatable/equatable.dart';
import 'package:eventora/features/events/data/event_model.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class EventLoadRequested extends EventEvent {}

class EventCreateRequested extends EventEvent {
  final EventModel event;

  const EventCreateRequested({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventFilterChanged extends EventEvent {
  final String? category;
  final int? maxPrice;

  const EventFilterChanged({this.category, this.maxPrice});

  @override
  List<Object?> get props => [category, maxPrice];
}

class EventSearchChanged extends EventEvent {
  final String query;

  const EventSearchChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

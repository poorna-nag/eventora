import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/bookings/bloc/booking_bloc.dart';
import 'package:eventora/features/bookings/data/booking_repository.dart';
import 'package:eventora/features/events/bloc/event_bloc.dart';
import 'package:eventora/features/events/bloc/event_event.dart';
import 'package:eventora/features/events/data/event_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final eventRepository = EventRepository();
    final bookingRepository = BookingRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(AuthCheckRequested()),
        ),
        BlocProvider<EventBloc>(
          create: (context) => EventBloc(eventRepository: eventRepository)
            ..add(EventLoadRequested()),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(
            bookingRepository: bookingRepository,
            authRepository: authRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Eventora',
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: NavigationService.onGenerateRoute,
        initialRoute: AppRoutes.sp,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFFF6F6F6),
          fontFamily: 'GoogleSans',
        ),
      ),
    );
  }
}

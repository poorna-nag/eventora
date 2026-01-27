import 'package:eventora/features/bookings/booking_screen.dart';
import 'package:eventora/features/create/presentation/create_screen.dart';
import 'package:eventora/features/events/home_view_screen.dart';
import 'package:eventora/features/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeViewScreen(),
    CreateScreen(),
    BookingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String? profileImage;
          if (state is AuthAuthenticated) {
            profileImage = state.user.profileImageUrl;
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Create',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: _currentIndex == 3
                      ? Colors.orange
                      : Colors.grey,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.white,
                    backgroundImage: profileImage != null
                        ? CachedNetworkImageProvider(profileImage)
                        : null,
                    child: profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 20,
                            color: _currentIndex == 3
                                ? Colors.orange
                                : Colors.grey,
                          )
                        : null,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

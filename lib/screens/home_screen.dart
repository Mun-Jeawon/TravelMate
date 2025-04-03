import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:travelmate/map_screen.dart'; // Google Maps 화면 추가
import 'explore_screen.dart';
import 'saved_places_screen.dart';
import 'trips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(),
    const SavedPlacesScreen(),
    const TripsScreen(),
    const MapScreen(), // 기존 TripsScreen 대신 MapScreen 사용
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // Trips 대신 Map 아이콘
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map), // Trips 대신 Map 아이콘
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/app_state.dart';
import '../models/place.dart';
import '../services/map_service.dart';
import 'place_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final MapService _mapService = MapService();
  final TextEditingController _searchController = TextEditingController();
  PlaceType _selectedType = PlaceType.attraction;
  List<Place> _searchResults = [];
  bool _isLoading = false;

  // Default to a sample location (can be updated with user's location)
  LatLng _currentLocation = const LatLng(37.7749, -122.4194); // San Francisco

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _mapService.searchNearbyPlaces(
        _currentLocation,
        _searchController.text,
        _selectedType,
        5000, // 5km radius
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for places',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                  onSubmitted: (_) => _searchPlaces(),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeChip(PlaceType.attraction, 'Attractions'),
                      _buildTypeChip(PlaceType.restaurant, 'Restaurants'),
                      _buildTypeChip(PlaceType.accommodation, 'Accommodations'),
                      _buildTypeChip(PlaceType.other, 'Other'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? const Center(
              child: Text('Search for places to explore'),
            )
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return _buildPlaceCard(place);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(PlaceType type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedType == type,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedType = type;
            });
            _searchPlaces();
          }
        },
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            place.type == PlaceType.attraction
                ? Icons.attractions
                : place.type == PlaceType.restaurant
                ? Icons.restaurant
                : place.type == PlaceType.accommodation
                ? Icons.hotel
                : Icons.place,
            color: Colors.blue,
          ),
        ),
        title: Text(place.name),
        subtitle: Text(
          place.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              place.rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.star, color: Colors.amber, size: 16),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                final appState = Provider.of<AppState>(context, listen: false);
                appState.addPlace(place);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${place.name} saved')),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailsScreen(place: place),
            ),
          );
        },
      ),
    );
  }
}


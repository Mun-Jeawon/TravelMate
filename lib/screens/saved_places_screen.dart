import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/place.dart';
import 'place_details_screen.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final savedPlaces = appState.savedPlaces;

          if (savedPlaces.isEmpty) {
            return const Center(
              child: Text('No saved places yet'),
            );
          }

          return ListView.builder(
            itemCount: savedPlaces.length,
            itemBuilder: (context, index) {
              final place = savedPlaces[index];
              return _buildPlaceCard(context, place);
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place) {
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
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            final appState = Provider.of<AppState>(context, listen: false);
            appState.removePlace(place);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${place.name} removed')),
            );
          },
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


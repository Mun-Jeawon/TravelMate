import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import 'add_itinerary_item_screen.dart';
import 'itinerary_item_details_screen.dart';
import 'trip_map_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripMapScreen(trip: trip),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Get the latest version of the trip
          final currentTrip = appState.trips.firstWhere(
                (t) => t.id == trip.id,
            orElse: () => trip,
          );

          return Column(
            children: [
              _buildTripHeader(context, currentTrip),
              const Divider(),
              Expanded(
                child: _buildItineraryList(context, currentTrip),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItineraryItemScreen(trip: trip),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context, Trip trip) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(trip.startDate);
    final endDate = dateFormat.format(trip.endDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.destination,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text('$startDate - $endDate'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.list, size: 16),
              const SizedBox(width: 4),
              Text('${trip.itinerary.length} activities planned'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryList(BuildContext context, Trip trip) {
    if (trip.itinerary.isEmpty) {
      return const Center(
        child: Text('No activities planned yet'),
      );
    }

    // Sort itinerary items by start time
    final sortedItinerary = List<ItineraryItem>.from(trip.itinerary)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Group by day
    final Map<String, List<ItineraryItem>> itemsByDay = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final item in sortedItinerary) {
      final day = dateFormat.format(item.startTime);
      if (!itemsByDay.containsKey(day)) {
        itemsByDay[day] = [];
      }
      itemsByDay[day]!.add(item);
    }

    final days = itemsByDay.keys.toList()..sort();

    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, dayIndex) {
        final day = days[dayIndex];
        final items = itemsByDay[day]!;
        final dayDate = DateTime.parse(day);
        final dayFormatted = DateFormat('EEEE, MMM d').format(dayDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                dayFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((item) => _buildItineraryItem(context, item)),
          ],
        );
      },
    );
  }

  Widget _buildItineraryItem(BuildContext context, ItineraryItem item) {
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(item.startTime);
    final endTime = timeFormat.format(item.endTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItineraryItemDetailsScreen(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTime,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'to $endTime',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.place.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    item.isAlarmEnabled ? Icons.notifications_active : Icons.notifications_off,
                    color: item.isAlarmEnabled ? Colors.blue : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


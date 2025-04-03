import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../models/itinerary_item.dart';
import '../services/map_service.dart';

class TripMapScreen extends StatefulWidget {
  final Trip trip;

  const TripMapScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _TripMapScreenState createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Map<String, Marker> _markers = {};
  Map<String, Polyline> _polylines = {};
  bool _isLoading = true;
  String _selectedDay = '';
  List<String> _days = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (widget.trip.itinerary.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Group itinerary items by day
    final Map<String, List<ItineraryItem>> itemsByDay = {};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (final item in widget.trip.itinerary) {
      final day = dateFormat.format(item.startTime);
      if (!itemsByDay.containsKey(day)) {
        itemsByDay[day] = [];
      }
      itemsByDay[day]!.add(item);
    }

    _days = itemsByDay.keys.toList()..sort();
    if (_days.isNotEmpty) {
      _selectedDay = _days.first;
      await _loadDayRoute(_selectedDay, itemsByDay[_selectedDay]!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDayRoute(String day, List<ItineraryItem> items) async {
    // Sort items by start time
    items.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Clear existing markers and polylines
    setState(() {
      _markers = {};
      _polylines = {};
    });

    // Add markers for each place
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final marker = Marker(
        markerId: MarkerId(item.id),
        position: item.place.location,
        infoWindow: InfoWindow(
          title: item.place.name,
          snippet: DateFormat('h:mm a').format(item.startTime),
        ),
      );

      _markers[item.id] = marker;

      // Add polylines between consecutive places
      if (i < items.length - 1) {
        final nextItem = items[i + 1];
        final routePoints = await _mapService.getRoutePoints(
          item.place.location,
          nextItem.place.location,
        );

        final polyline = Polyline(
          polylineId: PolylineId('${item.id}_${nextItem.id}'),
          points: routePoints,
          color: Colors.blue,
          width: 3,
        );

        _polylines['${item.id}_${nextItem.id}'] = polyline;
      }
    }

    setState(() {});

    // Move camera to fit all markers
    if (items.isNotEmpty && _mapController != null) {
      final bounds = _calculateBounds(items.map((item) => item.place.location).toList());
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> positions) {
    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Map'),
        bottom: _days.isNotEmpty
            ? PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _days.map((day) {
                  final dayDate = DateTime.parse(day);
                  final dayFormatted = DateFormat('MMM d').format(dayDate);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(dayFormatted),
                      selected: _selectedDay == day,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDay = day;
                          });
                          final itemsByDay = widget.trip.itinerary
                              .where((item) => DateFormat('yyyy-MM-dd').format(item.startTime) == day)
                              .toList();
                          _loadDayRoute(day, itemsByDay);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.trip.itinerary.isEmpty
          ? const Center(child: Text('No activities planned yet'))
          : GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // Default to San Francisco
          zoom: 12,
        ),
        markers: _markers.values.toSet(),
        polylines: _polylines.values.toSet(),
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}


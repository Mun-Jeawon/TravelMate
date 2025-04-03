import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/app_state.dart';
import '../models/trip.dart';
import '../models/place.dart';
import '../models/itinerary_item.dart';
import '../services/map_service.dart';


class AddItineraryItemScreen extends StatefulWidget {
  final Trip trip;

  const AddItineraryItemScreen({Key? key, required this.trip}) : super(key: key);

  @override
  _AddItineraryItemScreenState createState() => _AddItineraryItemScreenState();
}

class _AddItineraryItemScreenState extends State<AddItineraryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final MapService _mapService = MapService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  bool _isAlarmEnabled = true;

  Place? _selectedPlace;
  List<Place> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize selected date to the first day of the trip if it's in the future
    if (widget.trip.startDate.isAfter(DateTime.now())) {
      _selectedDate = widget.trip.startDate;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.trip.startDate,
      lastDate: widget.trip.endDate,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Ensure end time is after start time
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _searchPlaces() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Use the trip destination as the center for search
      final results = await _mapService.searchNearbyPlaces(
        const LatLng(37.7749, -122.4194), // This would be the trip location in a real app
        _searchController.text,
        PlaceType.attraction, // Default to attraction, but could be changed
        5000, // 5km radius
      );

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    }
  }

  void _addItineraryItem() {
    if (_formKey.currentState!.validate() && _selectedPlace != null) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final newItem = ItineraryItem(
        id: const Uuid().v4(),
        startTime: startDateTime,
        endTime: endDateTime,
        place: _selectedPlace!,
        notes: _notesController.text,
        isAlarmEnabled: _isAlarmEnabled,
      );

      appState.addItineraryItem(newItem);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedPlace!.name} added to itinerary')),
      );
    } else if (_selectedPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a place')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activity'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search for a place',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final place = _searchResults[index];
                      return ListTile(
                        title: Text(place.name),
                        subtitle: Text(place.address),
                        selected: _selectedPlace?.id == place.id,
                        onTap: () {
                          setState(() {
                            _selectedPlace = place;
                          });
                        },
                      );
                    },
                  ),
                ),
              if (_selectedPlace != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Selected Place',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(_selectedPlace!.name),
                    subtitle: Text(_selectedPlace!.address),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedPlace = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Date and Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Time'),
                      subtitle: Text(_startTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectStartTime(context),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Time'),
                      subtitle: Text(_endTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectEndTime(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Enable Reminder'),
                subtitle: const Text('Get notified before this activity'),
                value: _isAlarmEnabled,
                onChanged: (value) {
                  setState(() {
                    _isAlarmEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addItineraryItem,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Add to Itinerary'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


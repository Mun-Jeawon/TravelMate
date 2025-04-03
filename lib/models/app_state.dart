import 'package:flutter/foundation.dart';
import 'place.dart';
import 'trip.dart';
import 'itinerary_item.dart';

class AppState with ChangeNotifier {
  List<Place> _savedPlaces = [];
  List<Trip> _trips = [];
  Trip? _currentTrip;

  List<Place> get savedPlaces => _savedPlaces;
  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;

  void addPlace(Place place) {
    _savedPlaces.add(place);
    notifyListeners();
  }

  void removePlace(Place place) {
    _savedPlaces.remove(place);
    notifyListeners();
  }

  void createTrip(Trip trip) {
    _trips.add(trip);
    _currentTrip = trip;
    notifyListeners();
  }

  void updateTrip(Trip trip) {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      _trips[index] = trip;
      if (_currentTrip?.id == trip.id) {
        _currentTrip = trip;
      }
      notifyListeners();
    }
  }

  void deleteTrip(Trip trip) {
    _trips.removeWhere((t) => t.id == trip.id);
    if (_currentTrip?.id == trip.id) {
      _currentTrip = null;
    }
    notifyListeners();
  }

  void setCurrentTrip(Trip trip) {
    _currentTrip = trip;
    notifyListeners();
  }

  void addItineraryItem(ItineraryItem item) {
    if (_currentTrip != null) {
      final updatedTrip = _currentTrip!.copyWith(
        itinerary: [..._currentTrip!.itinerary, item],
      );
      updateTrip(updatedTrip);
    }
  }

  void updateItineraryItem(ItineraryItem oldItem, ItineraryItem newItem) {
    if (_currentTrip != null) {
      final index = _currentTrip!.itinerary.indexWhere((i) => i.id == oldItem.id);
      if (index != -1) {
        final updatedItinerary = List<ItineraryItem>.from(_currentTrip!.itinerary);
        updatedItinerary[index] = newItem;
        final updatedTrip = _currentTrip!.copyWith(itinerary: updatedItinerary);
        updateTrip(updatedTrip);
      }
    }
  }

  void removeItineraryItem(ItineraryItem item) {
    if (_currentTrip != null) {
      final updatedItinerary = _currentTrip!.itinerary.where((i) => i.id != item.id).toList();
      final updatedTrip = _currentTrip!.copyWith(itinerary: updatedItinerary);
      updateTrip(updatedTrip);
    }
  }
}


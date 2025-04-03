import 'package:flutter/foundation.dart';
import 'place.dart';

class ItineraryItem {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Place place;
  final String notes;
  final bool isAlarmEnabled;

  ItineraryItem({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.place,
    this.notes = '',
    this.isAlarmEnabled = true,
  });

  ItineraryItem copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Place? place,
    String? notes,
    bool? isAlarmEnabled,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      place: place ?? this.place,
      notes: notes ?? this.notes,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
    );
  }
}


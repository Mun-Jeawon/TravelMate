import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'review.dart';

enum PlaceType {
  attraction,
  restaurant,
  accommodation,
  other
}

class Place {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final PlaceType type;
  final String? imageUrl;
  final List<Review> reviews;
  final double rating;
  final String address;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    this.imageUrl,
    this.reviews = const [],
    this.rating = 0.0,
    required this.address,
  });

  Place copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? location,
    PlaceType? type,
    String? imageUrl,
    List<Review>? reviews,
    double? rating,
    String? address,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      reviews: reviews ?? this.reviews,
      rating: rating ?? this.rating,
      address: address ?? this.address,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as polyline;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  LatLng? _destination;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];

  final String proxyUrl = 'https://cors-anywhere.herokuapp.com/'; // 프록시 URL
  final String googleAPIKey = "AIzaSyBh9yyNCW4uD2nnHm7keY3v7-yH0ZHVaJY"; // 🔑 API 키 입력
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: "AIzaSyBh9yyNCW4uD2nnHm7keY3v7-yH0ZHVaJY");
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// 📌 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    mapController.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14.0));
  }

  /// 📌 목적지 선택
  void _setDestination(LatLng destination, String placeName) {
    setState(() {
      _destination = destination;
      _markers.add(
        Marker(
          markerId: MarkerId("destination"),
          position: destination,
          infoWindow: InfoWindow(title: placeName),
        ),
      );
    });

    _getPolyline();
  }

  /// 📌 경로(폴리라인) 가져오기
  Future<void> _getPolyline() async {
    if (_currentPosition == null || _destination == null) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(_destination!.latitude, _destination!.longitude),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        polylineCoordinates.clear();
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  /// 📌 Google Maps에서 길찾기 실행
  void _launchNavigation() async {
    if (_destination == null) return;

    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${_destination!.latitude},${_destination!.longitude}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  /// 📌 장소 자동완성 검색
  Future<List<Prediction>> _getPlacePredictions(String input) async {
    PlacesAutocompleteResponse response = await places.autocomplete(input);
    return response.predictions;
  }

  /// 📌 검색된 장소 선택 후 처리
  void _selectPlace(Prediction prediction) async {
    PlacesDetailsResponse detail =
    await places.getDetailsByPlaceId(prediction.placeId!);

    double lat = detail.result.geometry!.location.lat;
    double lng = detail.result.geometry!.location.lng;
    _setDestination(LatLng(lat, lng), prediction.description!);

    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.7749, -122.4194), // 기본 위치 (샌프란시스코)
              zoom: 12,
            ),
            markers: _markers,
            polylines: _polylines,
            onTap: (LatLng pos) {
              _setDestination(pos, "선택한 장소");
            },
          ),

          /// 🔍 **검색 바 추가**
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: TypeAheadField<Prediction>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "장소 검색...",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await _getPlacePredictions(pattern);
              },
              itemBuilder: (context, Prediction suggestion) {
                return ListTile(
                  title: Text(suggestion.description!),
                );
              },
              onSuggestionSelected: _selectPlace,
            ),
          ),

          /// 🚗 **네비게이션 버튼 추가**
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: _launchNavigation,
              child: Text("네비게이션 시작"),
            ),
          ),
        ],
      ),
    );
  }
}

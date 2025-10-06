import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  latlong.LatLng? _currentPosition;
  bool _isLoading = false;
  String? _error;
  bool _isServiceEnabled = false;
  bool _isPermissionGranted = false;
  MapController? _mapController;

  latlong.LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isServiceEnabled => _isServiceEnabled;
  bool get isPermissionGranted => _isPermissionGranted;
  MapController? get mapController => _mapController;

  // Initialize location service
  Future<bool> init() async {
    _isLoading = true;
    _error = null;
    _mapController = MapController();
    notifyListeners();

    try {
      final success = await _locationService.init();
      if (success) {
        _isServiceEnabled = _locationService.isServiceEnabled;
        _isPermissionGranted = _locationService.isPermissionGranted;

        // Get current position
        final position = await _locationService.getCurrentPosition();
        _currentPosition = position;
      } else {
        _error = 'Failed to initialize location service';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _isServiceEnabled && _isPermissionGranted;
  }

  // Get current location
  Future<latlong.LatLng?> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      _currentPosition = position;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _currentPosition;
  }

  // Request location permission
  Future<bool> requestPermission() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final granted = await _locationService.requestPermission();
      _isPermissionGranted = granted;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _isPermissionGranted;
  }

  // Request location service
  Future<bool> requestService() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final enabled = await _locationService.requestService();
      _isServiceEnabled = enabled;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _isServiceEnabled;
  }

  // Calculate distance between two points
  double calculateDistance(latlong.LatLng start, latlong.LatLng end) {
    return _locationService.calculateDistance(start, end);
  }

  // Format distance for display
  String formatDistance(double distanceInKm) {
    return _locationService.formatDistance(distanceInKm);
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(latlong.LatLng position) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final address = await _locationService.getAddressFromCoordinates(position);
      _isLoading = false;
      notifyListeners();
      return address;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Get coordinates from address
  Future<latlong.LatLng?> getCoordinatesFromAddress(String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coordinates = await _locationService.getCoordinatesFromAddress(address);
      _isLoading = false;
      notifyListeners();
      return coordinates;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Search nearby places
  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required latlong.LatLng center,
    required String placeType,
    double radius = 1000,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final places = await _locationService.searchNearbyPlaces(
        center: center,
        placeType: placeType,
        radius: radius,
      );
      _isLoading = false;
      notifyListeners();
      return places;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get directions
  Future<Map<String, dynamic>?> getDirections({
    required latlong.LatLng origin,
    required latlong.LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directions = await _locationService.getDirections(
        origin: origin,
        destination: destination,
        mode: mode,
      );
      _isLoading = false;
      notifyListeners();
      return directions;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Move map to position
  void moveMapToPosition(latlong.LatLng position, {double zoom = 14.0}) {
    _mapController?.move(position, zoom);
  }

  
  // Create marker
  Marker createMarker({
    required String markerId,
    required latlong.LatLng position,
    String? infoWindowTitle,
    String? infoWindowSnippet,
    Widget? icon,
    bool draggable = false,
  }) {
    return _locationService.createMarker(
      markerId: markerId,
      position: position,
      infoWindowTitle: infoWindowTitle,
      infoWindowSnippet: infoWindowSnippet,
      icon: icon,
      draggable: draggable,
    );
  }

  // Create circle
  CircleMarker createCircle({
    required String circleId,
    required latlong.LatLng center,
    double radius = 100,
    Color color = Colors.blue,
    double strokeWidth = 2,
  }) {
    return _locationService.createCircle(
      circleId: circleId,
      center: center,
      radius: radius,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  // Create polyline
  Polyline createPolyline({
    required String polylineId,
    required List<latlong.LatLng> points,
    Color color = Colors.blue,
    double width = 5,
  }) {
    return _locationService.createPolyline(
      polylineId: polylineId,
      points: points,
      color: color,
      width: width,
    );
  }

  // Create OpenStreetMap tile layer
  TileLayer createOpenStreetMapTileLayer() {
    return _locationService.createOpenStreetMapTileLayer();
  }

  // Create custom tile layer
  TileLayer createCustomTileLayer({
    String urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    String userAgent = 'com.zibene.security',
    double maxZoom = 19,
  }) {
    return _locationService.createCustomTileLayer(
      urlTemplate: urlTemplate,
      userAgent: userAgent,
      maxZoom: maxZoom,
    );
  }

  // Enable background location
  Future<void> enableBackgroundMode() async {
    try {
      await _locationService.enableBackgroundMode();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Disable background location
  Future<void> disableBackgroundMode() async {
    try {
      await _locationService.disableBackgroundMode();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Update current position
  void updatePosition(latlong.LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear location data
  void clearLocationData() {
    _currentPosition = null;
    _error = null;
    _mapController?.dispose();
    _mapController = null;
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
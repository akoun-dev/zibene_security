import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class LocationService {
  final Location _location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  latlong.LatLng? _currentLocation;

  // Initialize location service
  Future<bool> init() async {
    try {
      _serviceEnabled = await _location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _location.requestService();
        if (!_serviceEnabled) {
          return false;
        }
      }

      _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return false;
        }
      }

      // Get current location
      _currentLocation = await _location.getLocation().then((location) {
        if (location.latitude != null && location.longitude != null) {
          return latlong.LatLng(location.latitude!, location.longitude!);
        }
        return null;
      });

      // Listen to location changes
      _location.onLocationChanged.listen((LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          _currentLocation = latlong.LatLng(locationData.latitude!, locationData.longitude!);
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error initializing location service: $e');
      return false;
    }
  }

  // Get current location
  Future<latlong.LatLng?> getCurrentLocation() async {
    try {
      if (_currentLocation == null) {
        final location = await _location.getLocation();
        if (location.latitude != null && location.longitude != null) {
          _currentLocation = latlong.LatLng(location.latitude!, location.longitude!);
        }
      }
      return _currentLocation;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  // Get current position as LatLng
  Future<latlong.LatLng?> getCurrentPosition() async {
    return await getCurrentLocation();
  }

  // Check if location service is enabled
  bool get isServiceEnabled => _serviceEnabled;

  // Check if location permission is granted
  bool get isPermissionGranted => _permissionGranted == PermissionStatus.granted;

  // Request location permission
  Future<bool> requestPermission() async {
    try {
      _permissionGranted = await _location.requestPermission();
      return _permissionGranted == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  // Request location service
  Future<bool> requestService() async {
    try {
      _serviceEnabled = await _location.requestService();
      return _serviceEnabled;
    } catch (e) {
      debugPrint('Error requesting location service: $e');
      return false;
    }
  }

  // Enable background location updates
  Future<void> enableBackgroundMode() async {
    try {
      await _location.enableBackgroundMode(enable: true);
    } catch (e) {
      debugPrint('Error enabling background location: $e');
    }
  }

  // Disable background location updates
  Future<void> disableBackgroundMode() async {
    try {
      await _location.enableBackgroundMode(enable: false);
    } catch (e) {
      debugPrint('Error disabling background location: $e');
    }
  }

  // Calculate distance between two points
  double calculateDistance(latlong.LatLng start, latlong.LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  // Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }

  // Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(latlong.LatLng position) async {
    // In a real app, you would use Nominatim API or similar
    // For demo purposes, return a mock address
    return '123 Main St, New York, NY 10001';
  }

  // Get coordinates from address (geocoding)
  Future<latlong.LatLng?> getCoordinatesFromAddress(String address) async {
    // In a real app, you would use Nominatim API or similar
    // For demo purposes, return mock coordinates (New York City)
    return const latlong.LatLng(40.7128, -74.0060);
  }

  // Search nearby places
  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required latlong.LatLng center,
    required String placeType,
    double radius = 1000, // meters
  }) async {
    // In a real app, you would use Overpass API or similar
    // For demo purposes, return mock data
    return [
      {
        'name': 'Security Office Downtown',
        'address': '456 Security Ave, New York, NY 10002',
        'location': const latlong.LatLng(40.7138, -74.0070),
        'distance': 0.5,
        'rating': 4.8,
      },
      {
        'name': '24/7 Security Services',
        'address': '789 Protection Blvd, New York, NY 10003',
        'location': const latlong.LatLng(40.7148, -74.0080),
        'distance': 1.2,
        'rating': 4.5,
      },
    ];
  }

  // Get directions between two points
  Future<Map<String, dynamic>?> getDirections({
    required latlong.LatLng origin,
    required latlong.LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    // In a real app, you would use OSRM API or similar
    // For demo purposes, return mock data
    return {
      'distance': 5.2, // km
      'duration': 15, // minutes
      'polyline': [
        origin,
        const latlong.LatLng(40.7130, -74.0065),
        const latlong.LatLng(40.7135, -74.0070),
        destination,
      ],
      'steps': [
        {
          'instruction': 'Head north on Main St',
          'distance': 0.3,
          'duration': 2,
        },
        {
          'instruction': 'Turn right onto Security Ave',
          'distance': 4.9,
          'duration': 13,
        },
      ],
    };
  }

  
  // Create marker for flutter_map
  Marker createMarker({
    required String markerId,
    required latlong.LatLng position,
    String? infoWindowTitle,
    String? infoWindowSnippet,
    Widget? icon,
    bool draggable = false,
  }) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: Icon(
        Icons.location_on,
        color: Colors.red,
        size: 40,
      ),
    );
  }

  // Create circle for flutter_map
  CircleMarker createCircle({
    required String circleId,
    required latlong.LatLng center,
    double radius = 100,
    Color color = Colors.blue,
    double strokeWidth = 2,
  }) {
    return CircleMarker(
      point: center,
      radius: radius,
      color: color.withValues(alpha: 0.3),
      borderColor: color,
      borderStrokeWidth: strokeWidth,
    );
  }

  // Create polyline for flutter_map
  Polyline createPolyline({
    required String polylineId,
    required List<latlong.LatLng> points,
    Color color = Colors.blue,
    double width = 5,
  }) {
    return Polyline(
      points: points,
      color: color,
      strokeWidth: width,
    );
  }

  // Create tile layer for OpenStreetMap
  TileLayer createOpenStreetMapTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.zibene.security',
      maxZoom: 19,
    );
  }

  // Create custom tile layer (useful for different map styles)
  TileLayer createCustomTileLayer({
    String urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    String userAgent = 'com.zibene.security',
    double maxZoom = 19,
  }) {
    return TileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: userAgent,
      maxZoom: maxZoom,
    );
  }
}

// Travel mode for directions
enum TravelMode {
  driving,
  walking,
  bicycling,
  transit,
}
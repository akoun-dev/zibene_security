import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../providers/location_provider.dart';
import 'package:provider/provider.dart';

class OpenStreetMapWidget extends StatefulWidget {
  final latlong.LatLng? initialPosition;
  final double initialZoom;
  final List<Marker>? markers;
  final List<CircleMarker>? circles;
  final List<Polyline>? polylines;
  final bool showCurrentLocation;
  final bool enableUserInteraction;
  final Function(latlong.LatLng)? onTap;
  final Function(MapPosition)? onPositionChanged;

  const OpenStreetMapWidget({
    super.key,
    this.initialPosition,
    this.initialZoom = 14.0,
    this.markers,
    this.circles,
    this.polylines,
    this.showCurrentLocation = true,
    this.enableUserInteraction = true,
    this.onTap,
    this.onPositionChanged,
  });

  @override
  State<OpenStreetMapWidget> createState() => _OpenStreetMapWidgetState();
}

class _OpenStreetMapWidgetState extends State<OpenStreetMapWidget> {
  late MapController _mapController;
  latlong.LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentPosition = widget.initialPosition;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (widget.showCurrentLocation) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      _currentPosition = await locationProvider.getCurrentLocation();
      if (_currentPosition != null) {
        _mapController.move(_currentPosition!, widget.initialZoom);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialPosition ?? const latlong.LatLng(40.7128, -74.0060),
            initialZoom: widget.initialZoom,
            minZoom: 2.0,
            maxZoom: 19.0,
            interactionOptions: InteractionOptions(
              flags: widget.enableUserInteraction
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
            onTap: widget.onTap != null
                ? (tapPosition, point) => widget.onTap!(point)
                : null,
            onPositionChanged: widget.onPositionChanged != null
                ? (position, hasGesture) => widget.onPositionChanged!(position)
                : null,
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.zibene.security',
              maxZoom: 19,
            ),

            // Current location marker
            if (widget.showCurrentLocation && _currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition!,
                    width: 40,
                    height: 40,
                    child: Column(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            // Custom markers
            if (widget.markers != null && widget.markers!.isNotEmpty)
              MarkerLayer(markers: widget.markers!),

            // Circles
            if (widget.circles != null && widget.circles!.isNotEmpty)
              CircleLayer(circles: widget.circles!),

            // Polylines
            if (widget.polylines != null && widget.polylines!.isNotEmpty)
              PolylineLayer(polylines: widget.polylines!),

            // Zoom controls
            if (widget.enableUserInteraction)
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center, currentZoom + 1);
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 4),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        _mapController.move(_mapController.camera.center, currentZoom - 1);
                      },
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 4),
                    FloatingActionButton.small(
                      heroTag: 'current_location',
                      onPressed: () async {
                        await _getCurrentLocation();
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Public method to move map to specific position
  void moveToPosition(latlong.LatLng position, {double? zoom}) {
    _mapController.move(position, zoom ?? _mapController.camera.zoom);
  }

  // Public method to add marker
  void addMarker(Marker marker) {
    setState(() {
      // This would be handled by the parent widget
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
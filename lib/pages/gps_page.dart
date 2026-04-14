import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  String _status = 'Tap the button to get your current location.';
  Position? _currentPosition;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _status = 'Checking location services...';
    });

    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = null;
        _status = 'Location services are disabled.';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = null;
        _status = 'Location permission was denied.';
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = position;
        _status = 'Location updated successfully.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentPosition = null;
        _status = 'Failed to get location: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS Access')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gps_fixed, size: 72),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (_currentPosition != null) ...[
                Text('Latitude: ${_currentPosition!.latitude}'),
                const SizedBox(height: 8),
                Text('Longitude: ${_currentPosition!.longitude}'),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

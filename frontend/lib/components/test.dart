import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  void _getLocation() async{
    loc.Location location = loc.Location();
  loc.LocationData? currentLocation;

  try {
    //Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }
    }

    // Check if permission is granted
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        print('Location permission denied');
        return;
      }
    }

    // Fetch current location
    currentLocation = await location.getLocation();
    print(currentLocation);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentLocation.latitude!,currentLocation.longitude!);

  // Get the first placemark (if available)
  Placemark place = placemarks[0];
    String finalLocation = "${place.locality},${place.administrativeArea},${place.country}";
  } catch (e) {
    print('Error fetching location: $e');
    return;
  }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(onPressed: _getLocation, child: Text("fetch location")),
      ),
    );
  }
}
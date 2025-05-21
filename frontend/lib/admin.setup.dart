import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'package:frontend/config.dart';

class AdminSetupPage extends StatefulWidget {
  @override
  _AdminSetupPageState createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  late SharedPreferences prefs;
  final _permitController = TextEditingController();
  Location? _currentLocation;

  String? selectedLogo;

  final List<Map<String, dynamic>> logos = [
    {'icon': Icons.local_hospital, 'label': 'Red Cross'},
    {'icon': Icons.fire_truck, 'label': 'Civil Defence'},
  ];

  Color get primaryColor {
    switch (selectedLogo) {
      case 'Red Cross':
        return Colors.redAccent;
      case 'Civil Defence':
        return Colors.blue.shade800;
      default:
        return  Colors.brown;
    }
  }

  @override
  void initState() {
    super.initState();
    initSharedPref();
    _getLocation();
  }

  Future<void> _getLocation() async {
    loc.Location location = loc.Location();

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      final locData = await location.getLocation();
      await placemarkFromCoordinates(locData.latitude!, locData.longitude!);

      setState(() {
        _currentLocation = Location(
          latitude: locData.latitude,
          longitude: locData.longitude,
        );
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void logout() {
    prefs.clear();
    Navigator.pushNamed(context, '/login');
  }

  Future<void> submitCenter() async {
    print(selectedLogo);
    print(_currentLocation);
    print(_permitController.text);
    if (selectedLogo == null || _currentLocation == null || _permitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final body = {
      'adminId': prefs.getString("userId"),
      'centerType': selectedLogo,
      'address': {
        'latitude': _currentLocation!.latitude.toString(),
        'longtitude': _currentLocation!.longitude.toString(),
      },
    };

    try {
      final response = await http.post(
        Uri.parse(url + '/centreResgistration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final centerId = jsonDecode(response.body)['body'];
        await prefs.setString("centerId", centerId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Center registered successfully!')),
        );
        uploadPermit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> uploadPermit() async {
    final filePath = _permitController.text;
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a permit file first.')),
      );
      return;
    }

    final uri = Uri.parse("$url/createRequest");

    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('permit', filePath),
    );
    request.fields['admin'] = prefs.getString("userId")!;
    request.fields['center'] = prefs.getString("centerId")!;
    request.fields['isActivated'] = "false";

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent successfully!')),
        );
        await prefs.clear();
        Navigator.pushNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Admin Setup'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40),
                      Text(
                        'Register Emergency Center',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 30),

                      ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text(
                          _permitController.text.isEmpty
                              ? 'Select Institution Permit'
                              : 'Selected: ${_permitController.text.split('/').last}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                          );
                          if (result != null && result.files.single.path != null) {
                            _permitController.text = result.files.single.path!;
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Permit selected: ${result.files.single.name}')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No permit selected')),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 30),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Center Type:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: logos.map((logo) {
                          final isSelected = selectedLogo == logo['label'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLogo = logo['label'];
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: primaryColor.withOpacity(0.4)),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    )
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    logo['icon'],
                                    size: 36,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    logo['label'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: submitCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Text('Submit Info', style: TextStyle(fontSize: 18)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          minimumSize: Size(double.infinity, 55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_currentLocation != null)
              Positioned(
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Location {
  final double? latitude;
  final double? longitude;

  Location({this.latitude, this.longitude});
}

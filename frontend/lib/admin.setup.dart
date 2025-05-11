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

  int crewCount = 0;
  List<TextEditingController> crewNameControllers = [];
  List<TextEditingController> crewPhoneControllers = [];

  int vehicleCount = 0;
  List<TextEditingController> plateControllers = [];
  List<TextEditingController> modelControllers = [];
  List<TextEditingController> companyControllers = [];
  List<TextEditingController> yearControllers = [];

  String? selectedLogo;

  final List<Map<String, dynamic>> logos = [
    {'icon': Icons.local_hospital, 'label': 'Red Cross'},
    {'icon': Icons.fire_truck, 'label': 'Civil Defence'},
  ];

  @override
  void initState() {
    super.initState();
    initSharedPref();
    _getLocation();
  }

  Future<void> _getLocation() async {
    loc.Location location = loc.Location();
    loc.LocationData? _currentLocation;

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled');
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          print('Location permission denied');
          return;
        }
      }

      _currentLocation = await location.getLocation();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation.latitude!,
        _currentLocation.longitude!,
      );

      Placemark place = placemarks[0];
      print(_currentLocation.latitude);
      print(_currentLocation.longitude);

      setState(() {
        this._currentLocation = Location(
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation.longitude,
        );
      });
    } catch (e) {
      print('Error fetching location: $e');
      return;
    }
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void logout() {
    prefs.clear();
    Navigator.pushNamed(context, '/login');
  }

  void _generateCrewFields() {
    crewNameControllers = List.generate(crewCount, (_) => TextEditingController());
    crewPhoneControllers = List.generate(crewCount, (_) => TextEditingController());
  }

  void _generateVehicleFields() {
    plateControllers = List.generate(vehicleCount, (_) => TextEditingController());
    modelControllers = List.generate(vehicleCount, (_) => TextEditingController());
    companyControllers = List.generate(vehicleCount, (_) => TextEditingController());
    yearControllers = List.generate(vehicleCount, (_) => TextEditingController());
  }

      Future<void> sendCrewData(centerId) async {
        if(crewCount == 0) {ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter the crew count'),
          ));}
          else{
      // Prepare the crew data from the form
      List<Map<String, dynamic>> crewMembers = [];
      for (int i = 0; i < crewCount; i++) {
        crewMembers.add({
          'fullName': crewNameControllers[i].text,
          'phoneNb': crewPhoneControllers[i].text,
          'isBusy' : false,
          'center':centerId
        });
      }
      // Prepare the body of the request for crew data
      Map<String, dynamic> data = {
        'crewArray': crewMembers
      };

      try {
        final response = await http.post(
          Uri.parse(url+'/registerCrew'), // Replace with your API endpoint URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          // Successfully sent the crew data to the backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crew data successfully sent!')),
          );
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send crew data. Status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending crew data: $e')),
        );
      }
    }
  }

    Future<void> sendvehicleData(centerId) async {
      if(vehicleCount == 0) {ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter the vehicle count'),
          ));}
          else{
      // Prepare the crew data from the form
      List<Map<String, dynamic>> vehicules = [];
      for (int i = 0; i < vehicleCount; i++) {
        vehicules.add({
          'plateNb': plateControllers[i].text,
          'model': modelControllers[i].text,
          'company': companyControllers[i].text,
          'year': yearControllers[i].text,
          'isOccupied':false,
          'center':centerId
        });
      }
      // Prepare the body of the request for crew data
      Map<String, dynamic> data = {
        'arrayVehicules': vehicules
      };

      try {
        final response = await http.post(
          Uri.parse(url+'/vehiculeRegistration'), // Replace with your API endpoint URL
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          print(jsonDecode(response.body));
          // Successfully sent the crew data to the backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crew data successfully sent!')),
          );
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send crew data. Status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending crew data: $e')),
        );
        }
      }
    }

  Future<void> submitCenter() async {
    if (selectedLogo == null && vehicleCount <=0 && crewCount <=0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please make sure location and logo are selected.')),
      );
      return;
    }
    final body = {
      'adminId':prefs.getString("userId"),
      'centerType': selectedLogo,
      'address':{
        'latitude': _currentLocation!.latitude.toString(),
        'longtitude': _currentLocation!.longitude.toString(),
      },
      'workersCount': crewCount,
      'vehiculesCount': vehicleCount
    };

    try {
      final response = await http.post(
        Uri.parse(url+'/centreResgistration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final centerId = jsonDecode(response.body)['body'];
        prefs.setString("centerId", centerId);
        await sendCrewData(centerId);
        await sendvehicleData(centerId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Center registered successfully!')),
        );
        Navigator.pushNamed(context, '/adminFeed');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send data. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Admin Setup'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                );
                if (result != null && result.files.single.path != null) {
                  _permitController.text = result.files.single.path!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permit selected: ${result.files.single.name}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No permit selected')),
                  );
                }
              },
              child: Text(_permitController.text.isEmpty
                  ? 'Select Institution Permit'
                  : 'Selected: ${_permitController.text.split('/').last}'),
            ),
            SizedBox(height: 16),
            if (_currentLocation != null)
              Text('Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}'),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Center Type:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: logos.map((logo) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLogo = logo['label'];
                        });
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: selectedLogo == logo['label']
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            child: Icon(
                              logo['icon'],
                              size: 30,
                              color: selectedLogo == logo['label'] ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            logo['label'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selectedLogo == logo['label'] ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'How many crew members?'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                crewCount = int.tryParse(val) ?? 0;
                _generateCrewFields();
                setState(() {});
              },
            ),
            ...List.generate(crewCount, (index) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crew Member ${index + 1}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: crewNameControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: crewPhoneControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'How many vehicles?'),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                vehicleCount = int.tryParse(val) ?? 0;
                _generateVehicleFields();
                setState(() {});
              },
            ),
            ...List.generate(vehicleCount, (index) => Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle ${index + 1}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: plateControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Plate Number',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: modelControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Model',
                        prefixIcon: Icon(Icons.car_repair),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: companyControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Company',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: yearControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitCenter,
              child: Text('Proceed to Admin Feed'),
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











  

  
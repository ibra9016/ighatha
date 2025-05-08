import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class AdminSetupPage extends StatefulWidget {
  @override
  _AdminSetupPageState createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  late SharedPreferences prefs;
  final _permitController = TextEditingController();
  LatLng? _selectedLocation;

  int crewCount = 0;
  List<TextEditingController> crewNameControllers = [];
  List<TextEditingController> crewPhoneControllers = [];

  int vehicleCount = 0;
  List<TextEditingController> plateControllers = [];
  List<TextEditingController> modelControllers = [];
  List<TextEditingController> companyControllers = [];
  List<TextEditingController> yearControllers = [];

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void logout() {
    prefs.clear();
    Navigator.pushNamed(context, '/login');
  }

  void _pickLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _generateCrewFields() {
    crewNameControllers =
        List.generate(crewCount, (_) => TextEditingController());
    crewPhoneControllers =
        List.generate(crewCount, (_) => TextEditingController());
  }

  void _generateVehicleFields() {
    plateControllers = List.generate(vehicleCount, (_) => TextEditingController());
    modelControllers = List.generate(vehicleCount, (_) => TextEditingController());
    companyControllers = List.generate(vehicleCount, (_) => TextEditingController());
    yearControllers = List.generate(vehicleCount, (_) => TextEditingController());
  }

  void _proceed() {
    if (_permitController.text.isEmpty ||
        _selectedLocation == null ||
        crewNameControllers.any((c) => c.text.isEmpty) ||
        crewPhoneControllers.any((c) => c.text.isEmpty) ||
        plateControllers.any((c) => c.text.isEmpty) ||
        modelControllers.any((c) => c.text.isEmpty) ||
        companyControllers.any((c) => c.text.isEmpty) ||
        yearControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    Navigator.pushNamed(context, '/adminFeed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    SnackBar(
                        content: Text(
                            'Permit selected: ${result.files.single.name}')),
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
            ElevatedButton(
              onPressed: () async {
                _pickLocation(LatLng(33.8938, 35.5018)); // Example coords
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location picked!')));
              },
              child: Text('Pick Center Location on Map'),
            ),
            if (_selectedLocation != null)
              Text(
                  'Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'),
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
            ...List.generate(crewCount, (index) => Column(
                  children: [
                    TextField(
                        controller: crewNameControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Crew ${index + 1} Full Name')),
                    TextField(
                        controller: crewPhoneControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Crew ${index + 1} Phone')),
                  ],
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
            ...List.generate(vehicleCount, (index) => Column(
                  children: [
                    TextField(
                        controller: plateControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Vehicle ${index + 1} Plate Number')),
                    TextField(
                        controller: modelControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Vehicle ${index + 1} Model')),
                    TextField(
                        controller: companyControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Vehicle ${index + 1} Company')),
                    TextField(
                        controller: yearControllers[index],
                        decoration: InputDecoration(
                            labelText: 'Vehicle ${index + 1} Year')),
                  ],
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _proceed,
              child: Text('Proceed to Admin Feed'),
            ),
          ],
        ),
      ),
    );
  }
}

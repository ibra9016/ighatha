import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class PostScreen extends StatefulWidget {
  final File image;

  const PostScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
    String finalLocation="";
  final TextEditingController _textController = TextEditingController();
  late SharedPreferences prefs;

  Future<void> _getLocation() async{
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
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentLocation.latitude!,currentLocation.longitude!);

  // Get the first placemark (if available)
  Placemark place = placemarks[0];
    finalLocation = "${place.locality},${place.administrativeArea}}";
  } catch (e) {
    print('Error fetching location: $e');
    return;
  }
  }
  

  Future<void> _post() async{
     await _getLocation();
     if(finalLocation == "") return;
    final File _imageFile = widget.image;
    var request = http.MultipartRequest("POST", Uri.parse(url+'/postRegistration'));
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',  
        _imageFile!.path,
      ),
    );
    
    request.fields['description'] = _textController.text;
    request.fields['postedBy'] = prefs.getString('userId')!;
    request.fields['location'] = finalLocation;
    request.fields['isAssigned'] = "false";
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      print('Upload successful: $data');
      Navigator.pop(context,true);
    } 
    else {
      print('Upload failed: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }
  void initPrefs() async{ 
   prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write your post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write something about this photo...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Image.file(widget.image),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _post,
              child: Text("Post"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
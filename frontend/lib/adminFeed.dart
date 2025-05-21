import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/components/adminNavBar.dart';
import 'package:frontend/components/locationMapPage.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/config.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/postDetailPage.dart';
import 'package:intl/intl.dart';

class AdminFeed extends StatefulWidget {
  const AdminFeed({super.key});

  @override
  State<AdminFeed> createState() => _AdminFeedState();
}

class _AdminFeedState extends State<AdminFeed> {
  late Future<List<Map<String, String>>> _imageData;
  late SharedPreferences prefs;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  int _selectedIndex = 0;

  void takePic() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      final shouldrefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(image: _imageFile!),
        ),
      );
      if (shouldrefresh == true) {
        setState(() {
          _imageData = fetchImageUrls();
        });
      }
    }
  }

  Future<List<Map<String, String>>> fetchImageUrls() async {
    final response = await http.post(Uri.parse(url + '/getPics'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['file'];

      List<Map<String, String>> mappedItems = await Future.wait(
        data.map<Future<Map<String, String>>>((item) async {
          String locationString = 'Unknown location';
          double latitude = 0.0;
          double longitude = 0.0;

          try {
            final location = item['location'];
            print("this is the location $location");
            if (location != null &&
                location['latitude'] != null &&
                location['longtitude'] != null) {
              latitude = double.parse(location['latitude']);
              longitude = double.parse(location['longtitude']);

              List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
                print("this is local $placemarks");
              if (placemarks.isNotEmpty) {
                Placemark place = placemarks[0];
                locationString = "${place.locality}, ${place.administrativeArea}";
                
              }
            }
          } catch (e) {
            print('Error parsing location for item ${item['_id']}: $e');
          }

          return {
            'imageUrl': url + (item['image']['filepath'] ?? ''),
            'description': item['description'] ?? 'No description available',
            'userName': item['postedBy']['username'] ?? 'Unknown User',
            '_id': item['_id'] ?? 'no id',
            'isAssigned': item['isAssigned'].toString(),
            'location': locationString,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
          };
        }).toList(),
      );
      return mappedItems.reversed.toList();
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    _imageData = fetchImageUrls();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void handleStatusAssign(String postId) async {
    String? centerId = prefs.getString("centerId");

    final responseCrew = await http.post(
      Uri.parse(url + '/fetchCrew'),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"centerId": centerId}),
    );

    final responseVehicle = await http.post(
      Uri.parse(url + '/fetchVehicules'),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"centerId": centerId}),
    );

    if (responseCrew.statusCode != 200 || responseVehicle.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch crew members or vehicles')),
      );
      return;
    }

    final crewjson = jsonDecode(responseCrew.body);
    final vehiclejson = jsonDecode(responseVehicle.body);

    List<dynamic> crewList = crewjson['body'];
    List<dynamic> vehicleList = vehiclejson['body'];

    List<Map<String, dynamic>> crewMembers = crewList.map<Map<String, dynamic>>((item) {
      return {
        'id': item['_id']?.toString() ?? '',
        'fullName': item['fullName']?.toString() ?? '',
        'status': item['isBusy'] ?? false,
      };
    }).toList();

    List<Map<String, dynamic>> vehicles = vehicleList.map<Map<String, dynamic>>((item) {
      return {
        'id': item['_id']?.toString() ?? '',
        'model': item['model']?.toString() ?? '',
        'company': item['company']?.toString() ?? '',
        'status': item['isOccupied'] ?? false,
      };
    }).toList();

    String? selectedCrew;
    String? selectedVehicle;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Assign Mission'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCrew,
                  hint: Text('Select Crew Member'),
                  items: crewMembers.map((crew) {
                    bool isOccupied = crew['status'] == true;
                    return DropdownMenuItem<String>(
                      value: crew['id'],
                      child: Row(
                        children: [
                          Text(
                            crew['fullName'] ?? '',
                            style: TextStyle(
                              color: isOccupied ? Colors.grey : Colors.black,
                            ),
                          ),
                          if (isOccupied)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '(Occupied)',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selected = crewMembers.firstWhere(
                      (crew) => crew['id'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty && selected['status'] != true) {
                      setStateDialog(() {
                        selectedCrew = value;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('This crew member is occupied. Please select another.')),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  hint: Text('Select Vehicle'),
                  items: vehicles.map((vehicle) {
                    bool isOccupied = vehicle['status'] == true;
                    return DropdownMenuItem<String>(
                      value: vehicle['id'],
                      child: Row(
                        children: [
                          Text(
                            '${vehicle['model']} (${vehicle['company']})',
                            style: TextStyle(
                              color: isOccupied ? Colors.grey : Colors.black,
                            ),
                          ),
                          if (isOccupied)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '(Occupied)',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selected = vehicles.firstWhere(
                      (vehicle) => vehicle['id'] == value,
                      orElse: () => {},
                    );
                    if (selected.isNotEmpty && selected['status'] != true) {
                      setStateDialog(() {
                        selectedVehicle = value;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('This vehicle is occupied. Please select another.')),
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedCrew != null && selectedVehicle != null) {
                    final missionResponse = await http.post(
                      Uri.parse(url + '/createMission'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'Admin': prefs.getString("userId"),
                        'post': postId,
                        'crewMember': selectedCrew,
                        'vehicle': selectedVehicle,
                        'isCompleted': false,
                        'startTime': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
                      }),
                    );

                    if (missionResponse.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mission assigned successfully!')),
                      );
                      setState(() {
                        _imageData = fetchImageUrls(); // Refresh posts
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to assign task')),
                      );
                    }
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select both crew and vehicle')),
                    );
                  }
                },
                child: Text('Assign'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Text(
          "Latest",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 4,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _imageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final posts = snapshot.data!;
          if (posts.isEmpty) return Center(child: Text('No Posts found'));

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _imageData = fetchImageUrls();
              });
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  key: ValueKey(post['_id']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(
                          imageUrl: post['imageUrl']!,
                          description: post['description']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    color: Colors.grey[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        post['userName']!.isNotEmpty
                                            ? post['userName']![0]
                                            : '?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post['userName']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (post['location']!.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                final double latitude =
                                                    double.parse(post['latitude']!);
                                                final double longitude =
                                                    double.parse(post['longitude']!);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => LocationMapPage(
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                post['location']!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (post['isAssigned'] == 'false') {
                                    handleStatusAssign(post['_id']!);
                                  }
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: post['isAssigned'] == 'true'
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    post['isAssigned'] == 'true'
                                        ? 'Assigned'
                                        : 'Not Assigned',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                            image: DecorationImage(
                              image: NetworkImage(post['imageUrl']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            post['description']!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            takePic();
            setState(() {
              _selectedIndex = 0;
            });
          } 
          else if (index == 2) {
            Navigator.pushNamed(context, '/adminAccount');
          }
        },
      ),
    );
  }
}

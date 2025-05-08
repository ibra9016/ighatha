import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/postDetailPage.dart';

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

  void _takePic() async {
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

      return data.map<Map<String, String>>((item) {
        return {
          'imageUrl': url + item['image']['filepath'],
          'description': item['description'] ?? 'No description available',
          'userName': item['postedBy']['username'] ?? 'Unknown User',
          '_id': item['_id'] ?? 'no id',
          'isAssigned': item['isAssigned'].toString(),
          'location': item['location'] ?? '',
        };
      }).toList().reversed.toList();
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

  void logout() async {
    await prefs.clear();
    Navigator.pushNamed(context, '/login');
  }

  void handleStatusAssign(String postId) async {
     String? centerId = prefs.getString("centerId");

  // Fetch crew members from API
  final response = await http.post(
    Uri.parse(url + '/fetchCrew'),
    headers: {"Content-type": "application/json"},
    body: jsonEncode({"adminId": centerId}),
  );

  if (response.statusCode != 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch crew members')),
    );
    return;
  }

  final jsonres = jsonDecode(response.body);
  //print(jsonres);
  String? selectedCrew;
  String? selectedVehicle;

  // ✅ Populate crewMembers list from response
     List<dynamic> crewList = jsonres['body'];

  List<Map<String, String>> crewMembers = crewList.map<Map<String, String>>((item) {
    return {
      'id': item['_id']?.toString() ?? '',
      'fullName': item['fullName']?.toString() ?? '',
    };
  }).toList();

  // Example vehicle list (can fetch from API too if needed)
  List<String> vehicles = ['Vehicle 1', 'Vehicle 2', 'Vehicle 3'];

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Assign Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCrew,
              hint: Text('Select Crew Member'),
              items: crewMembers.map((crew) {
                return DropdownMenuItem(
                  value: crew['id'],
                  child: Text(crew['fullName'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                selectedCrew = value;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedVehicle,
              hint: Text('Select Vehicle'),
              items: vehicles.map((vehicle) {
                return DropdownMenuItem(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (value) {
                selectedVehicle = value;
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
                final assignResponse = await http.post(
                  Uri.parse(url + '/assignTask'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'postId': postId,
                    'crewMemberId': selectedCrew, // Send ID
                    'vehicle': selectedVehicle,
                  }),
                );

                if (assignResponse.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task assigned successfully!')),
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
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
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
          if (posts.isEmpty)
            return Center(child: Text('No Posts found'));

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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                            Text(
                                              post['location']!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
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
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            _takePic();
            setState(() {
              _selectedIndex = 0;
            });
          } else if (index == 2) {
            Navigator.pushNamed(context, '/notifications');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/account');
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: 'New Post'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

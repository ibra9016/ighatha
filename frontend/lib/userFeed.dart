import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/postDetailPage.dart';

class Userfeed extends StatefulWidget {
  const Userfeed({super.key});

  @override
  State<Userfeed> createState() => _UserfeedState();
}

class _UserfeedState extends State<Userfeed> {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(image: _imageFile!),
        ),
      );
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
          '_id': item['_id'] ?? 'no id'
        };
      }).toList().reversed.toList();
    } else {
      throw Exception('Failed to load images');
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
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(toolbarHeight: 60,
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
              backgroundColor: Colors.blueAccent, // solid blue color
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
            return Center(child: Text('No images found'));

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              String imageUrl = posts[index]['imageUrl']!;
              String description = posts[index]['description']!;
              String userName = posts[index]['userName']!;
              String postId = posts[index]['_id']!;

              return GestureDetector(
                key: ValueKey(postId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(
                        imageUrl: imageUrl,
                        description: description,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  color: Colors.grey[400],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                userName.isNotEmpty ? userName[0] : '?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Post Image
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Description
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
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
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            
             _takePic();
            setState(() {
              _selectedIndex=0;
            });
            
          } else if (index == 2) {
            Navigator.pushNamed(context, '/account');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo_rounded),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/components/userNavBar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<UserAccountPage> {
  int _selectedIndex = 2;
  late SharedPreferences prefs;
  String username = '';

  void _takePic() async {
    File? _imageFile;
     final ImagePicker _picker = ImagePicker();
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

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? 'Guest';
    });
    
  }

  Future<void> _logout() async {
    await prefs.clear(); // or remove specific keys
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login'); // or your login route
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UserBottomNavBar(
                           currentIndex: _selectedIndex,
                           onTap: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                            if (index == 1) {
                              _takePic();
                              setState(() {
                                _selectedIndex = 2;
                              });
                            } else if (index == 0) {
                              Navigator.pushNamed(context, '/userFeed');
                            }
                            } 
                    )
    );
  }
}

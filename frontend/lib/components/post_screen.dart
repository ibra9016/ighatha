import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostScreen extends StatefulWidget {
  final File image;

  const PostScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _textController = TextEditingController();
  late SharedPreferences prefs;
  

  Future<void> _post() async{
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
    request.fields['location'] = "random";
    request.fields['isAssigned'] = "false";
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      print('Upload successful: $data');
      Navigator.pushNamed(context, '/feed');
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
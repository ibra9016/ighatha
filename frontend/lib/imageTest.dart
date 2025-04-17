import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class myImage extends StatefulWidget {
  
  const myImage({super.key});

  @override
  State<myImage> createState() => _myImageState();
}

class _myImageState extends State<myImage> {
  late SharedPreferences prefs;
  late String text = "";
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String base64 = "";
  void _converImageBase64() async{
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if(image == null) return ;
    Uint8List imageBytes = await image!.readAsBytes();
    setState(() {
      base64 = base64Encode(imageBytes);
    });
    sendPic();
  }

  void sendPic() async{
    if(base64 == "") return;
    var regBody = {
      "image": base64
    };
    var response = await http.post(Uri.parse('http://192.168.1.101:3000/postRegistration'),
                                  headers: {"Content-type": "application/json"},
                                  body: jsonEncode(regBody));
    
    print(response.body);
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }
  void initPrefs() async{ 
   prefs = await SharedPreferences.getInstance();
  }

  void removeToken(){
    prefs.remove("token");
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            base64 == "" ? Container(child: Text(text),):Image.memory(base64Decode(base64),height: 150,width: 150),
            ElevatedButton(onPressed:() {removeToken();
              //_converImageBase64();
              }, 
            child: Text("remove token"))
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/myTextField.dart';
import 'package:frontend/components/my_button.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late SharedPreferences prefs;
  void loginUser() async{
    
    if(_usernameController.text.isEmpty && _passwordController.text.isEmpty){
      print("working");
      return;
    }
    var regBody = {
      "username": _usernameController.text,
      "password": _passwordController.text
    };

    var response = await http.post(
      Uri.parse(url+'/loginUser'),
      headers: {"Content-type": "application/json"},
      body: jsonEncode(regBody)
    );
    var jsonResponse = jsonDecode(response.body);
    if(jsonResponse['status']){
      var token = jsonResponse['token'];
      prefs.setString("token", token);
      Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(token);
      var username = jwtDecodedToken['username'];
      var isAdmin = jwtDecodedToken['isAdmin'];
      
        isAdmin == true?Navigator.pushNamed(context, '/adminPage'):
                        Navigator.pushNamed(context, '/userPage');
    
    }
    else{
      print("somethig went wrong");
    }
  }

  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }

  void forgotPass(){
    print("working");
  }
  @override
  Widget build(BuildContext context) {
    bool isObsecure = true;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:SafeArea(child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(repeat: ImageRepeat.noRepeat,
          opacity: 0.1,
          scale: 0.1,
          image:AssetImage("assets/images/abstract-cedar-tree-icon-vector-35451494.jpg")),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              //logo
              Image.asset(
                  "assets/images/images-removebg-preview.png",
                  height: 200,
                  width: 200,
                ),
          
              //welcome Back
              Text(
                'Welcome back Habibi',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20
                ),
              ),
              SizedBox(height: 50),
              //username textField
              Mytextfield(controller: _usernameController,
                            hintText: "Username",
                            obscureText: false),
              SizedBox(height: 10),
              //password textfield
              Mytextfield(
                controller: _passwordController,
                            hintText: "Password",
                            obscureText: true
              ),
              SizedBox(height: 20),
        
              //forgot password
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(onTap: () {forgotPass();},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey[600]),
                    ),),
                    SizedBox(width: 20),
                ],
              ),
        
              SizedBox(height: 20),
              //signin button
          
              MyButton(onTap: loginUser,buttonText: "Sign in",),
              SizedBox(height: 60),
              //not A member?
        
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    'Not Registered?',
                    style: TextStyle(color: Colors.grey[700],
                    fontSize: 16),
            
                  ),
        
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  )
                ],
              ),SizedBox(height: 50),
        
              MyButton(onTap: () {Navigator.pushNamed(context, '/register');},buttonText: "Sign Up",),
            ],
          ),
        ),
      )
      ) 
    );
  }
}
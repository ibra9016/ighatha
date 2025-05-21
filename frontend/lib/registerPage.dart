import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/myTextField.dart';
import 'components/my_button.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  var role = "";
    bool _obscureText = true;
    late SharedPreferences prefs;
    TextEditingController _usernamecontroller = TextEditingController();
    TextEditingController _emailcontroller = TextEditingController();
    TextEditingController _passwordController2 = TextEditingController();
  // ignore: unused_element
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void switchTabs() {
    if (role.isEmpty == true) {
      print("role is empty");
    } else {
      if (role == "user") {
        resgisterUser();
      } else {

      }
    }
  }

  void resgisterUser() async {
    if(_usernamecontroller.text.isEmpty && _passwordController2.text.isEmpty) return ;
    bool isAdmin = false;
    String email = _emailcontroller.text.trim().toLowerCase();
    var regBody = {
      "username": _usernamecontroller.text,
      "email": email,
      "password":_passwordController2.text,
      "isAdmin": isAdmin,
    };

    var response = await http.post(
      Uri.parse(url+'/userResgistration'),
      headers: {"Content-type": "application/json"},
      body: jsonEncode(regBody)
    );
    if(response.statusCode == 200){
      var jsonResponse = jsonDecode(response.body);
      var token = jsonResponse['token'];
      prefs.setString("token", token);
      Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(token);
      prefs.setString('userId', jwtDecodedToken['_id']);
      prefs.setString("username",jwtDecodedToken['username']);
      Navigator.pushNamed(context, '/userFeed');
    }
    setState(() {
      _usernamecontroller.clear();
      _passwordController2.clear();
    });
  }
  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void registerAdmin() async {
  if (_usernamecontroller.text.isEmpty && _passwordController2.text.isEmpty && _emailcontroller.text.isEmpty) return;
  bool isAdmin = true;
  String email = _emailcontroller.text.trim().toLowerCase();
  var regBody = {
    "username": _usernamecontroller.text,
    "email":email,
    "password": _passwordController2.text,
    "isAdmin": isAdmin,
    "isActive":false
  };

  var response = await http.post(
    Uri.parse(url + '/userResgistration'),
    headers: {"Content-type": "application/json"},
    body: jsonEncode(regBody),
  );

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    var token = jsonResponse['token'];
    prefs.setString("token", token);
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(token);
    prefs.setString('userId', jwtDecodedToken['_id']);
    prefs.setString("centerId", jwtDecodedToken['center']);
    prefs.setString("username", jwtDecodedToken['username']);
    Navigator.pushNamed(context, '/adminSetup');
  }

  setState(() {
    _usernamecontroller.clear();
    _emailcontroller.clear();
    _passwordController2.clear();
  });
}

  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:SafeArea(child: Center(
        child: Container(decoration: BoxDecoration(
          image: DecorationImage(repeat: ImageRepeat.noRepeat,
          opacity: 0.1,
          scale: 0.1,
          image:AssetImage("assets/images/abstract-cedar-tree-icon-vector-35451494.jpg")),
        ),
          child: Column(
            children: [
              SizedBox(height: 30),
              //logo
              Image.asset(
                  "assets/images/images-removebg-preview.png",
                  height: 180,
                  width: 200,
                ),
          
              //welcome Back
              Text(
                'Welcome Habibi',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20
                ),
              ),
              SizedBox(height: 30),
              //start
              Container(margin: const EdgeInsets.symmetric(horizontal: 50),
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8)
              ),
                child:  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(child: Container(
                         //padding: EdgeInsets.only(top: 5,left: 100,bottom: 5),
                         height: 40,
                         width: 100,
                        decoration: BoxDecoration(
                          color: 
                          role == "user"? Colors.grey[500]:Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text("User",style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                      )
                       ,
                      onTap: () {
                        setState(() {
                          role = "user";
                        });
                      },),
                      
                      SizedBox(width: 30),
                      GestureDetector(child: FittedBox(fit: BoxFit.fitHeight,child: Container(
                         //padding: EdgeInsets.only(top: 5,left: 10,right: 10,bottom: 5),
                         height:40,
                         width: 100,
                        decoration: BoxDecoration(
                          color:
                          role == "admin"? Colors.grey[500]:Colors.grey[400],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text("Admin",style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.bold
                          ),
                          ),
                        ),
                      ) 
                      ),
                      onTap: () {
                        setState(() {
                          role = "admin";
                        });
                      },)
                    ],
                  ),
                
              ),
              SizedBox(height: 20),
              //username textField
              if(role == "admin")...{
                Mytextfield(controller: _usernamecontroller,
                            hintText: "Username",
                            obscureText: false),
              SizedBox(height: 10),
              Mytextfield(
                controller: _emailcontroller,
                            hintText: "Email",
                            obscureText: false
              ),
              SizedBox(height: 10),
              //password textfield
              Mytextfield(
                controller: _passwordController2,
                            hintText: "Password",
                            obscureText: true
              ),
              SizedBox(height: 20),
          
              //signin button
          
              MyButton(onTap: () {registerAdmin();},buttonText: "Sign Up",),
              
              },
              if(role == "user")...{
                Mytextfield(controller: _usernamecontroller,
                            hintText: "Username",
                            obscureText: false),
              SizedBox(height: 10),
              Mytextfield(
                controller: _emailcontroller,
                            hintText: "Email",
                            obscureText: false
              ),
              SizedBox(height: 10),
              //password textfield
              Mytextfield(
                controller: _passwordController2,
                            hintText: "Password",
                            obscureText: true
              ),   
                    SizedBox(height: 20),
              //signin button
          
              MyButton(onTap: () {resgisterUser();},buttonText: "Sign Up",),
              
              },
              SizedBox(height: 30),
              
              //not A member?
              //end
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    'Already a User?',
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
          
              MyButton(onTap: () {Navigator.pushNamed(context, '/login');},buttonText: "Login",),
            ],
          ),
        ),
      )
      ) 
    );
  }
}

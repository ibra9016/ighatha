import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  var role = "";
  bool _obscureText = true;
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _emailController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
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
      } else {}
    }
  }

  void resgisterUser() async {
    var regBody = {
      "email": _emailController1.text,
      "password": _passwordController2.text,
    };

    var response = await http.post(
      Uri.parse('http://192.168.1.101:3000/userResgistration'),
      headers: {"Content-type": "application/json"},
      body: jsonEncode(regBody),
    );
    print(response.body);
    setState(() {
      _emailController1.clear();
      _passwordController2.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(224, 255, 255, 255),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 135, top: 10),
            child: Image.asset(
              "assets/images/images-removebg-preview.png",
              height: 180,
              width: 180,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 141, 23, 19),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   'Information Admin',
                  //   style: TextStyle(color: Colors.white, fontSize: 24),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          role = "user";
                        },
                        child: Text("User"),
                      ),
                      SizedBox(width: 40),
                      GestureDetector(
                        onTap: () {
                          role = "admin";
                        },
                        child: Text("Admin"),
                      ),
                    ],
                  ),
                  if(role == "user"){
                  SizedBox(height: 20),
                  TextField(
                    controller: _namecontroller,
                    decoration: InputDecoration(
                      hintText: ' Full Name',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(137, 73, 70, 70),
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _emailController1,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(137, 73, 70, 70),
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _passwordController2,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(137, 73, 70, 70),
                      ),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Registration logic here
                    },
                    child: GestureDetector(
                      onTap: () => {switchTabs()},
                      child: Text('Sign up'),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 141, 23, 19),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  }
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

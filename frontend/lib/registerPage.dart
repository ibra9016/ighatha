import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
    bool _obscureText = true;
      final TextEditingController _namecontroller = TextEditingController();
final TextEditingController _emailController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
      // ignore: unused_element
      void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }void resgisterUser() async{
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor: Color.fromARGB(224, 255, 255, 255),
      body: Stack(
        children: [
          //Positioned image
          // Positioned(
            
          //   top: 50,
          //   left: MediaQuery.of(context).size.width / 4, // Adjust as needed
          //   right: MediaQuery.of(context).size.width / 4, // Adjust as needed
          //   child: Image(
          //    image: AssetImage('images_removebg_preview_0Fy_icon.ico'),width: 5,
          //  ),
          // ),
        
          Container(
            child: Image.asset("assets/images/images-removebg-preview.png",height: 100,width: 100)
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
                  Text('Information Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
                  SizedBox(height: 20),
                  TextField(
                    controller: _namecontroller,
                    decoration: InputDecoration(
                      hintText: ' Full Name',
                      hintStyle: TextStyle(color: const Color.fromARGB(137, 73, 70, 70)),
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
                      hintStyle: TextStyle(color: const Color.fromARGB(137, 73, 70, 70)),
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
                      hintStyle: TextStyle(color: const Color.fromARGB(137, 73, 70, 70)),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
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
                    child: Text('Sign up'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 141, 23, 19),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
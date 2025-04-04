import 'package:flutter/material.dart';

class Usersignup extends StatefulWidget {
  const Usersignup({super.key});

  @override
  State<Usersignup> createState() => _UsersignupState();
}

class _UsersignupState extends State<Usersignup> {
    final TextEditingController _namecontroller = TextEditingController();
    final TextEditingController _phonecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Color.fromARGB(224, 255, 255, 255),
      body: Center(
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
              Text('Full Name & Phone Number', style: TextStyle(color: Colors.white, fontSize: 24)),
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
                controller: _phonecontroller,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: const Color.fromARGB(137, 73, 70, 70)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
                ElevatedButton(
                onPressed: () {
                
                },
                child: Text('Sing up'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 141, 23, 19), backgroundColor: Colors.white,
                ),
              ),
    
    ]   ) ,),),); 
  }
}
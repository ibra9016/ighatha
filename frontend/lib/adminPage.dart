import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({super.key});

  @override
  State<Adminpage> createState() => _AdminpageState();
}

class _AdminpageState extends State<Adminpage> {
  late SharedPreferences prefs;
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
    Navigator.pushNamed(context, '/login');
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("admin Page"),
          ElevatedButton(onPressed: () {removeToken();}, child: Text("remove token"))
        ],
      ),));
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userpage extends StatefulWidget {
  const Userpage({super.key});

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
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
          Text("user Page"),
          ElevatedButton(onPressed: () {removeToken();}, child: Text("remove token"))
        ],
      ),));
  }
}
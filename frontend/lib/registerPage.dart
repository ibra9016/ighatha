import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void resgisterUser() async{
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 200,width: 200,child: TextField(controller: usernameController,),),
          Container(height: 200,width: 200,child: TextField(controller: emailController,),),
          Container(height: 200,width: 200,child: TextField(controller: passwordController,),)
        ],)
      )
    );
  }
}
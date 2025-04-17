import 'package:flutter/material.dart';
import 'package:frontend/loginPage.dart';
import 'package:frontend/registerPage.dart';
import 'package:frontend/imageTest.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/adminPage.dart';
import 'package:frontend/userPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({
    @required this.token,
    Key? key,}):super(key: key);

  @override
  Widget build(BuildContext context) {
    late bool isAdmin;
    if(token != null){
      Map<String,dynamic> decodedToken = JwtDecoder.decode(token);
      print(decodedToken['isAdmin']);
      isAdmin = decodedToken['isAdmin'];
    }
    
    
    return MaterialApp(
      routes: {
        '/login':(context)=>Loginpage(),
        '/adminPage':(context)=>Adminpage(),
        '/userPage':(context)=>Userpage(),
        '/register':(context)=>Registerpage()
      },
      debugShowCheckedModeBanner: false,
        home:(Registerpage()
          
        //   token == null? Loginpage():
        // JwtDecoder.isExpired(token) == false? 
        // isAdmin == true?
        // Adminpage():Userpage()
        // :
        // Loginpage())
  )
  );
  }
}


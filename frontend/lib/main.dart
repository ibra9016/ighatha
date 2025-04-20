import 'package:flutter/material.dart';
import 'package:frontend/adminFeed.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/userFeed.dart';
import 'package:frontend/loginPage.dart';
import 'package:frontend/registerPage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getString('userId'));
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
        '/register':(context)=>Registerpage(),
        '/userFeed':(context)=>Userfeed(),
        '/adminFeed':(context)=>AdminFeed()
      },
      debugShowCheckedModeBanner: false,
        home:(
          
          token != null? 
                  isAdmin == true? AdminFeed():
                                  Userfeed():
          Loginpage()
  
  )
  );
  }
}


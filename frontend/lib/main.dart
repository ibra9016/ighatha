import 'package:flutter/material.dart';
import 'package:frontend/adminFeed.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/components/test.dart';
import 'package:frontend/userFeed.dart';
import 'package:frontend/loginPage.dart';
import 'package:frontend/registerPage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/admin.setup.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),center: prefs.getString('center')));
}

class MyApp extends StatelessWidget {
  final token;
  final center;
  const MyApp({
    @required this.token,
    @required this.center,
    Key? key,}):super(key: key);

  @override
  Widget build(BuildContext context) {
    late bool isAdmin;
    String? c;
    if(token != null){
      Map<String,dynamic> decodedToken = JwtDecoder.decode(token);
      isAdmin = decodedToken['isAdmin'];
    }
    
    
    return MaterialApp(
      routes: {
        '/login':(context)=>Loginpage(),
        '/register':(context)=>Registerpage(),
        '/userFeed':(context)=>Userfeed(),
        '/adminFeed':(context)=>AdminFeed(),
        '/adminSetup': (context) => AdminSetupPage()
      },
      debugShowCheckedModeBanner: false,
        home:(

          token != null? 
                  isAdmin == true? 
                         center == null? 
                                  AdminSetupPage():
                                  AdminFeed():
                    Userfeed():
           Loginpage()
  
  )
  );
  }
}


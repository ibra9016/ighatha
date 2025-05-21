import 'package:flutter/material.dart';
import 'package:frontend/adminFeed.dart';
import 'package:frontend/components/accountPage.dart';
import 'package:frontend/components/accountPageUser.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/components/test.dart';
import 'package:frontend/statisticsPage.dart';
import 'package:frontend/superAdminFeed.dart';
import 'package:frontend/userDisplay.dart';
import 'package:frontend/userFeed.dart';
import 'package:frontend/loginPage.dart';
import 'package:frontend/registerPage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/admin.setup.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(token: prefs.getString('token'),
                center: prefs.getString('centerId'),
                superAdmin:prefs.getBool("superAdmin")));
}

class MyApp extends StatelessWidget {
  final token;
  final center;
  final superAdmin;
  const MyApp({
    @required this.token,
    @required this.center,
    @required this.superAdmin,
    Key? key,}):super(key: key);

  @override
  Widget build(BuildContext context) {
    late bool isAdmin;
    late bool isActive;
    String? c;
    if(token != null){
      Map<String,dynamic> decodedToken = JwtDecoder.decode(token);
      isAdmin = decodedToken['isAdmin'];
      if(decodedToken['isActive'] != null){
      isActive = decodedToken['isActive'];
      }
    }
    
    
    return MaterialApp(
      routes: {
        '/login':(context)=>Loginpage(),
        '/register':(context)=>Registerpage(),
        '/userFeed':(context)=>Userfeed(),
        '/adminFeed':(context)=>AdminFeed(),
        '/adminSetup': (context) => AdminSetupPage(),
        '/adminAccount':(context) => AccountPage(),
        '/userAccount':(context)=> UserAccountPage(),
        '/superAdminfeed':(context)=>Superadminfeed(),
        '/usersDisplay':(context)=> UsersDisplayPage(),
        '/statistics':(context)=>StatisticsPage()
      },
      debugShowCheckedModeBanner: false,
        home:(
          token != null? 
            superAdmin == true? Superadminfeed():
                      isAdmin == true?
                          center == ""?
                                  AdminSetupPage():
                              isActive == false? Loginpage():
                                                  AdminFeed():
                     Userfeed():         
           Loginpage()
  )
  );
  }
}


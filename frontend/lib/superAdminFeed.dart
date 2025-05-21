import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/requestReview.dart';
import 'package:frontend/components/superAdminNav.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Superadminfeed extends StatefulWidget {
  const Superadminfeed({super.key});

  @override
  State<Superadminfeed> createState() => _SuperadminfeedState();
}

class _SuperadminfeedState extends State<Superadminfeed> {
  int _selectedIndex = 0;
  bool pendingExpanded = false;
  bool acceptedExpanded = false;  
  List<dynamic> pendingRequests = [];
  List<dynamic> acceptedRequests = [];
  late SharedPreferences prefs;
  String? username;

  Widget buildAcceptedDropdown() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.only(bottom: 16),
    child: ExpansionTile(
      initiallyExpanded: acceptedExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          acceptedExpanded = expanded;
        });
      },
      title: Text(
        'Recently Accepted (${acceptedRequests.take(5).length})',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: acceptedRequests.take(5).map((request) {
        return ListTile(
          title: Text(request["admin"]['username'] ?? 'Unknown User'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Center: ${request['center']['centerType'] ?? "N/A"}"),
            ],
          ),
          trailing: const Icon(Icons.check_circle, color: Colors.green),
        );
      }).toList(),
    ),
  );
}

Widget buildPendingDropdown() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.only(bottom: 16),
    child: ExpansionTile(
      initiallyExpanded: pendingExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          pendingExpanded = expanded;
        });
      },
      title: Text(
        'Pending Requests (${pendingRequests.length})',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: pendingRequests.map((request) {
        return ListTile(
          title: Text(request["admin"]['username'] ?? 'Unknown'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Center: ${request['center']['centerType'] ?? "N/A"}"),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewPage(requestData: request),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text("Review",style: TextStyle(color:  Colors.white,
                                                        fontWeight: FontWeight.bold ),)
          ),
        );
      }).toList(),
    ),
  );
}


@override
void initState(){
  super.initState();
  initPrefs();
  fetchData();
}

void fetchData() async{
  final response = await http.post(Uri.parse("$url/fetchRequests"),
                  headers: {"Content-type": "application/json"});
  if(response.statusCode == 200){
    setState(() {
    List<dynamic> allRequests = jsonDecode(response.body)['body'];
    pendingRequests = allRequests.where((request)=>request['isActivated']==false).toList();
    acceptedRequests = allRequests.where((request)=>request['isActivated']==true).toList();
    }); 
  }
  else{
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch Requests')),
    );
    return;
  }
}

void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? 'Guest';
  }
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Super Admin Feed'),
          backgroundColor: Colors.brown,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await prefs.clear();
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPendingDropdown(),
          buildAcceptedDropdown(),
        ],
      ),
    ),
    bottomNavigationBar: SuperAdminBottomNavBar(
      currentIndex: _selectedIndex, 
      onTap: (index) {
            setState(() {
              _selectedIndex = index;
                });
          if (index == 1) {
            Navigator.pushNamed(context, '/usersDisplay');

             } 
          else if (index == 2) {
            Navigator.pushNamed(context, '/statistics');
          }
          else if (index == 3) {
            Navigator.pushNamed(context, '/superAdminProfile');
          }
  }),
  );
}
}
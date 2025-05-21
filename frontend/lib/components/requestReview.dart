import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPage extends StatefulWidget {
  final dynamic requestData;

  const ReviewPage({super.key, required this.requestData});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late SharedPreferences prefs;
  late dynamic admin;
  late dynamic center;
  late String requestId;
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    admin = widget.requestData['admin'];
    center = widget.requestData['center'];
    requestId = widget.requestData['_id'];
    initPrefs();
    fetchData();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void fetchData() async {
    final userResponse = await http.post(
      Uri.parse("$url/findUser"),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"_id": admin['_id']}),
    );

    final centerResponse = await http.post(
      Uri.parse("$url/findUser"),
      headers: {"Content-type": "application/json"},
      body: jsonEncode({"_id": admin['_id']}),
    );

    if (userResponse.statusCode == 200) {
      setState(() {
        userInfo = jsonDecode(userResponse.body)['body'];
      });
      print("$url${widget.requestData['permitDocument']['filePath']}");
      
      // You can update state here if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user info')),
      );
    }
  }

  void acceptRequest(requestId) async{
    final response = await http.post(Uri.parse("$url/acceptRequest"),
                                      headers: {"Content-type": "application/json"},
                                      body: jsonEncode({"requestId":requestId}));
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request Accepted!')),
      );
      Navigator.pushNamed(context, '/superAdminfeed');
    }
  }
  
  void declineRequest(requestId) async{
    final response = await http.post(Uri.parse("$url/rejectRequest"),
                                      headers: {"Content-type": "application/json"},
                                      body: jsonEncode({"requestId":requestId}));
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected!')),
      );
      Navigator.pushNamed(context, '/superAdminfeed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Review Request"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Info", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text("Username: ${admin['username'] ?? 'N/A'}"),
                Text("Email: ${userInfo['email'] ?? 'N/A'}"),
                const Divider(height: 30),

                Text("Center Info", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text("Type: ${center['centerType'] ?? 'N/A'}"),
                Text("Location: ${center['location'] ?? 'N/A'}"),
                const Divider(height: 30),
                  Text("Permit Document", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),

                  Container(
                    height: 400,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: SfPdfViewer.network(
                      "$url${widget.requestData['permitDocument']['filePath']}",
                      canShowScrollStatus: true,
                      canShowPaginationDialog: true,
                    ),
                  ),

                  const Divider(height: 30),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        acceptRequest(widget.requestData['_id']);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Accept"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        declineRequest(widget.requestData['_id']);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("Decline"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

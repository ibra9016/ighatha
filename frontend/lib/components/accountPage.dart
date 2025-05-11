import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/components/adminNavBar.dart';
import 'package:frontend/components/post_screen.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/adminFeed.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 3;
  late SharedPreferences prefs;
  String username = 'Guest';
  String? centerId;
  List<dynamic> activeMissions = [];
  bool missionsExpanded = false;
  List<dynamic> finishedMissions = [];
bool finishedExpanded = false;
  List<dynamic> crew = [];
  List<dynamic> vehicles = [];
  bool loading = true;
  AdminFeed admin = AdminFeed();

  @override
  void initState() {
    super.initState();
    initPrefs();
    fetchAllData();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    centerId = prefs.getString("centerId");
    username = prefs.getString("username") ?? 'Guest';
  }

  void takePic() async {
    File? _imageFile;
     final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      Navigator.push(
        context,  
        MaterialPageRoute(
          builder: (context) => PostScreen(image: _imageFile!),
        ),
      );
    }
  }

  Future<void> fetchAllData() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      final missionResponse = await http.post(Uri.parse(url + "/getMission"),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"adminId": prefs.getString("userId")}));

      final crewResponse = await http.post(Uri.parse(url + "/fetchCrew"),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"centerId": centerId}));

      final vehicleResponse = await http.post(Uri.parse(url + "/fetchVehicules"),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"centerId": centerId}));

      if (crewResponse.statusCode == 200 && vehicleResponse.statusCode == 200) {
        final missionjson = jsonDecode(missionResponse.body);
        final crewjson = jsonDecode(crewResponse.body);
        final vehiclejson = jsonDecode(vehicleResponse.body);

        setState(() {
          List<dynamic> allMissions = missionjson['body'];
          activeMissions = allMissions.where((mission) => mission['isCompleted'] == false).toList();
          finishedMissions = allMissions.where((mission) => mission['isCompleted'] == true).toList();
          // Parsing Crew Members
          List<dynamic> crewList = crewjson['body'];
          crew = crewList.map((item) {
            return {
              'id':item['_id']?.toString(),
              'name': item['fullName']?.toString() ?? 'N/A',
              'status': item['isBusy'] ?? false
            };
          }).toList();

          // Parsing Vehicles
          List<dynamic> vehicleList = vehiclejson['body'];
          vehicles = vehicleList.map((item) {
            return {
              'id':item['_id']?.toString(),
              'model': item['model']?.toString() ?? 'N/A',
              'company': item['company']?.toString() ?? 'N/A',
              'status': item['isOccupied'] ?? false
            };
          }).toList();
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => loading = false);
    }
  }
  void deleteVehicle(String vehicleId) async{
    final deleteResponse = await http.post(Uri.parse(url+"/deleteVehicle"),
                                  headers: {"Content-type": "application/json"},
                                   body: jsonEncode({"vehicleId":vehicleId}));
    fetchAllData();                   
    print('Deleting vehicle with ID: $vehicleId');
  }

  void addNewVehicle() async{
    final pnController = TextEditingController();
    final modelController = TextEditingController();
    final companyController = TextEditingController();
    final yearController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Crew Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pnController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'company',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {
              if (pnController.text.isEmpty || modelController.text.isEmpty ||
                  companyController.text.isEmpty || yearController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }
              final body = {
                "arrayVehicules":{
                        'plateNb': pnController.text,
                        'model': modelController.text,
                        'company': companyController.text,
                        'year': yearController.text,
                        'isOccupied':false,
                        'center':centerId
              }};
              final response = await http.post(
                Uri.parse(url + "/vehiculeRegistration"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(body),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vehicle Added")),
                );
                fetchAllData(); // refresh UI
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to add vehicle")),
                );
              }
            },
          ),
        ],
      );
    },
  );
  }


  void kickCrewMember(String memberId) async {
    final deleteResponse = await http.post(Uri.parse(url+"/deleteMember"),
                                  headers: {"Content-type": "application/json"},
                                   body: jsonEncode({"memberId":memberId}));
    fetchAllData();                   
    print('Kicking crew member with ID: $memberId');
  }
  void addNewCrewMember() {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Crew Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields")),
                );
                return;
              }
              final body = {
                "crewArray":{
                        'fullName': name,
                        'phoneNb': name,
                        'isBusy' : false,
                        'center':centerId
              }};
              final response = await http.post(
                Uri.parse(url + "/registerCrew"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(body),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Member Added")),
                );
                fetchAllData(); // refresh UI
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to add member")),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

void markMissionAsDone(String missionId) async{
  final response = await http.post(
                Uri.parse(url + "/changeStatus"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"missionId":missionId}));
    print(jsonDecode(response.body));
    if(response.statusCode == 200){
      print("Entered");
      ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mission status changed")),
                );
                print(jsonDecode(response.body));
                fetchAllData();
    }
}

  Widget buildMissionDropdown() {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          initiallyExpanded: missionsExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              missionsExpanded = expanded;
            });
          },
          title: Text(
            'Active Missions (${activeMissions.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: activeMissions.map((mission) {
            final bool isCompleted = mission['isCompleted'] == true;
            final String responsible = mission['crewMember']?['fullName'] ?? 'Unnamed Mission';

            return ListTile(
              title: Text("$responsible's Mission"),
              subtitle: Text(
                isCompleted ? 'Accomplished' : 'Ongoing',
                style: TextStyle(
                  color: isCompleted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: isCompleted
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => markMissionAsDone(mission['_id']),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.green[800],
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        child: const Text("Mark as Done"),
                      ),
                    ),
            );
          }).toList(),
        ),
      );
    }

    Widget buildFinishedMissionDropdown() {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                initiallyExpanded: finishedExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    finishedExpanded = expanded;
                  });
                },
                title: Text(
                  'Finished Missions (${finishedMissions.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: finishedMissions.map((mission) {
                  final String responsible = mission['crewMember']?['fullName'] ?? 'Unnamed Mission';

                  return ListTile(
                    title: Text("$responsible's Mission"),
                    subtitle: const Text(
                      'Accomplished',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }




  Widget buildCrewCard(String title, List<dynamic> crewMembers) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(top: 16, bottom: 16), // Adjusted margin
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added some padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12), // Reduced space between title and list
            ...crewMembers.map((crewMember) {
              return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(crewMember['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  crewMember['status'] == true
                      ? const Text('Occupied', style: TextStyle(color: Colors.red, fontSize: 14))
                      : const Text('Available', style: TextStyle(color: Colors.green, fontSize: 14)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => kickCrewMember(crewMember['id']),
                  ),
                ],
              ),
            );
            }).toList(),
            ElevatedButton(
              onPressed: addNewCrewMember, // Call add new crew member method
              child: const Text('Add New Member'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleCard(String title, List<dynamic> vehicles) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...vehicles.map((vehicle) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.directions_car),
                      title: Text('${vehicle['model']} (${vehicle['company']})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          vehicle['status'] == true
                              ? const Text('Occupied', style: TextStyle(color: Colors.red, fontSize: 14))
                              : const Text('Available', style: TextStyle(color: Colors.green, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteVehicle(vehicle['id']),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: addNewVehicle,
                    child: const Text('Add New Vehicle'),
                  ),
                ],
              ),
            ),
          );
        }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAllData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Welcome $username',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                   buildMissionDropdown(),
                   buildFinishedMissionDropdown(),
                  buildCrewCard('Crew Members', crew),
                  buildVehicleCard('Vehicles', vehicles),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); 
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login'); 
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            bottomNavigationBar: AdminBottomNavBar(
                          currentIndex: _selectedIndex,
                          onTap: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                            if (index == 1) {
                              takePic();
                              setState(() {
                                _selectedIndex = 3;
                              });
                            } else if (index == 2) {
                              Navigator.pushNamed(context, '/notifications');
                            } else if (index == 0) {
                              Navigator.pushNamed(context, '/adminFeed');
                            }
                          },
                        ),
    );
  }
}

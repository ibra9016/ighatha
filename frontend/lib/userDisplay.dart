import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/components/superAdminNav.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config.dart'; // Make sure `url` is defined here

class UsersDisplayPage extends StatefulWidget {
  const UsersDisplayPage({super.key});

  @override
  State<UsersDisplayPage> createState() => _UsersDisplayPage();
}

class _UsersDisplayPage extends State<UsersDisplayPage> {
  int _selectedIndex = 1;
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 Future<void> fetchUsers() async {
      try {
        final response = await http.post(
          Uri.parse("$url/fetchAllUsers"),
          headers: {"Content-type": "application/json"},
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final allUsers = decoded['body'];

          // Filter out the "superadmin" user
          final visibleUsers = allUsers.where((user) =>
              (user['username']?.toLowerCase() ?? '') != 'superadmin').toList();

          setState(() {
            users = visibleUsers;
            filteredUsers = visibleUsers;
            isLoading = false;
          });
        } else {
          showError("Failed to load users");
        }
      } catch (e) {
        showError("An error occurred: $e");
      }
    }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      isLoading = false;
    });
  }

  void filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        final username = (user['username'] ?? '').toLowerCase();
        return username.contains(query);
      }).toList();
    });
  }

  Widget buildUserCard(dynamic user) {
    bool isAdmin = user['isAdmin'] == true;
    bool isBanned = user['isBanned'] == true; // Adjust if your backend uses a different key

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: isAdmin ? Colors.brown : Colors.grey[600],
          child: Icon(isAdmin ? Icons.shield : Icons.person, color: Colors.white, size: 28),
        ),
        title: Text(
          user['username'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isAdmin ? Colors.brown[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isAdmin ? 'Admin' : 'User',
            style: TextStyle(
              color: isAdmin ? Colors.brown[700] : Colors.blue[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Delete User',
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: () => confirmDeleteUser(user),
            ),
          ],
        ),
        onTap: () {
          // Optional: user detail page navigation here
        },
      ),
    );
  }

  void confirmDeleteUser(dynamic user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete ${user['username']}?'),
          content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                deleteUser(user);
              },
              child: const Text('Delete',style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser(dynamic user) async {
    final userId = user['_id']; // Adjust key as per your API data
    try {
      final response = await http.post(
        Uri.parse("$url/deleteUser"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({'_id': userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          fetchUsers();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete user')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }


  Widget buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Search users...",
          prefixIcon: Icon(Icons.search, color: Colors.brown),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Users"),
        backgroundColor: Colors.brown,
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildSearchBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) =>
                                buildUserCard(filteredUsers[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SuperAdminBottomNavBar(
      currentIndex: _selectedIndex, 
      onTap: (index) {
            setState(() {
              _selectedIndex = index;
                });
          if (index == 0) {
            Navigator.pushNamed(context, '/superAdminfeed');

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

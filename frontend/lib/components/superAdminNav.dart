import 'package:flutter/material.dart';

class SuperAdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SuperAdminBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'statistics'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
    );
  }
}

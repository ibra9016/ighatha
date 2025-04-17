import 'package:flutter/material.dart';
import 'package:frontend/loginPage.dart';

class Mytextfield extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const Mytextfield({super.key,
                    required this.controller,
                    required this.hintText,
                    required this.obscureText,
                    });

  @override
  State<Mytextfield> createState() => _MytextfieldState();
}

class _MytextfieldState extends State<Mytextfield> {
  @override
  Widget build(BuildContext context) {
    bool currentObsecureText = widget.obscureText;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: TextField(
      controller: widget.controller,
      obscureText: currentObsecureText,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: OutlineInputBorder(  
          borderSide: BorderSide(color: Colors.grey.shade400)
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        
      ),
    ),);
  }
}
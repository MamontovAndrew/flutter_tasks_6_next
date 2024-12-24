import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../models/user_profile.dart';
import 'auth_page.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  ProfileScreen({required this.userProfile});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _editProfile() async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userProfile: widget.userProfile),
      ),
    );

    if (updatedProfile != null) {
      setState(() {
        widget.userProfile.name = updatedProfile.name;
        widget.userProfile.email = updatedProfile.email;
        widget.userProfile.imagePath = updatedProfile.imagePath;
      });
    }
  }

  Future<void> _logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editProfile,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.userProfile.imagePath == null
                ? CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            )
                : CircleAvatar(
              radius: 50,
              backgroundImage: FileImage(File(widget.userProfile.imagePath!)),
            ),
            SizedBox(height: 16),
            Text(
              widget.userProfile.name.isNotEmpty
                  ? widget.userProfile.name
                  : 'Ваше имя',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              widget.userProfile.email.isNotEmpty
                  ? widget.userProfile.email
                  : 'Электронная почта',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
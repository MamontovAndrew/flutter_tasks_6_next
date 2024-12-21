import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  EditProfileScreen({required this.userProfile});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  String? _imagePath;

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _name = widget.userProfile.name;
    _email = widget.userProfile.email;
    _imagePath = widget.userProfile.imagePath;
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imagePath = pickedFile.path;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Обновляем профиль на сервере
        await apiService.updateUserProfile(_name, _email);

        final updatedProfile = UserProfile(
          name: _name,
          email: _email,
          imagePath: _imagePath,
        );
        Navigator.pop(context, updatedProfile);
      } catch (e) {
        // Покажем SnackBar с ошибкой
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении профиля: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Редактировать профиль'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imagePath == null
                        ? CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.add_a_photo),
                    )
                        : CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(_imagePath!)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(labelText: 'Имя'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите имя';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  TextFormField(
                    initialValue: _email,
                    decoration: InputDecoration(labelText: 'Электронная почта'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите электронную почту';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

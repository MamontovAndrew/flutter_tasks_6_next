import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/globals.dart';
import '../services/api_service.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      Fluttertoast.showToast(msg: 'Заполните все поля');
      return;
    }

    try {
      if (_isLogin) {
        try {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (response.session != null) {
            globalUserId = supabase.auth.currentUser?.id;

            Fluttertoast.showToast(msg: 'Вход выполнен успешно');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainNavigation()),
            );
          } else {
            Fluttertoast.showToast(msg: 'Неверная почта или пароль.');
          }
        } on AuthException catch (authError) {
          Fluttertoast.showToast(msg: 'Ошибка при входе: ${authError.message}');
        } catch (e) {
          Fluttertoast.showToast(msg: 'Неизвестная ошибка: $e');
        }

      } else {
        try {
          final response = await supabase.auth.signUp(
            email: email,
            password: password,
          );
          if (response.user != null) {
          globalUserId = response.user!.id;

          final userData = {
            'user_id': response.user!.id,
            'email': email,
            'username': name,
            'created_at': DateTime.now().toIso8601String(),
          };

          final userCreateResponse = await http.post(
            Uri.parse('http://localhost:8080/users'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(userData),
          );
          if (userCreateResponse.statusCode == 201) {
            Fluttertoast.showToast(
                msg: 'Регистрация успешна! Войдите в аккаунт.');
            setState(() {
              _isLogin = true;
            });
          } else {
            Fluttertoast.showToast(
                msg: 'Ошибка при создании пользователя в локальной БД.');
          }
          } else {
            Fluttertoast.showToast(msg: 'Регистрация не удалась.');
          }
        } on AuthException catch (authError) {
          Fluttertoast.showToast(msg: 'Ошибка при регистрации: ${authError.message}');
        } catch (e) {
          Fluttertoast.showToast(msg: 'Неизвестная ошибка: $e');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ошибка: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Вход' : 'Регистрация'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя'),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? 'Еще нет аккаунта? Зарегистрируйтесь'
                    : 'Уже есть аккаунт? Войдите',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

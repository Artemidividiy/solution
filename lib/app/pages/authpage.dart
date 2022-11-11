import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:solution/app/components/authform.dart';
import 'package:solution/app/pages/homepage.dart';

import '../components/registerform.dart';

enum FormType { auth, register }

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  FormType type = FormType.auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            type == FormType.auth ? AuthForm() : RegisterForm(),
            TextButton(
                onPressed: change,
                child: Text(type == FormType.auth ? "Register" : "Auth"))
          ],
        ),
      ),
    );
  }

  change() {
    setState(() {
      if (type == FormType.auth)
        type = FormType.register;
      else
        type = FormType.auth;
    });
  }
}

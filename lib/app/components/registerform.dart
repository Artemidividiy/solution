import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/user.dart';
import '../pages/homepage.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RegisterForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              validator: _emailValidator,
            ),
            TextFormField(
              controller: _passwordController,
              validator: _passwordValidator,
            ),
            ElevatedButton(onPressed: register, child: Text("Register"))
          ],
        ));
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return "cannot be empty";
    Future<bool> available = checkAvailable(value);
    bool synced = true;
    available.then((value) => synced = value);
    if (!synced) return "already taken";
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return "cannot be empty";
  }

  Future<bool> checkAvailable(String value) async {
    var client = PocketBase("http://127.0.0.1:8090");
    await client.admins
        .authViaEmail('artemiy.kasyanik@gmail.com', 'adminadmin');

    final pageResult = await client.users.getList(
      page: 1,
      perPage: 100,
      filter: 'created >= "2022-01-01 00:00:00"',
    );
    if (pageResult.items.firstWhere((element) => element.email == value,
            orElse: () => UserModel()) ==
        UserModel()) return true;
    return false;
  }

  void register() async {
    final client = PocketBase("http://127.0.0.1:8090");
    try {
      final user = await client.users.create(body: {
        'email': _emailController.text,
        'password': _passwordController.text,
        'passwordConfirm': _passwordController.text,
      });
      await User.set(
        newEmail: _emailController.text,
        newPassword: _passwordController.text,
        id: user.id,
      );
      if (formKey.currentState!.validate())
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
    } catch (e) {
      log("🍑");
    }
  }
}

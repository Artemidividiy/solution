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
  TextEditingController _passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: "email"),
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: _emailValidator,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: "password"),
                obscureText: true,
                controller: _passwordController,
                validator: _passwordValidator,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(labelText: "password"),
                obscureText: true,
                controller: _passwordConfirmController,
                validator: _passwordConfirmValidator,
              ),
            ),
            ElevatedButton(onPressed: register, child: Text("Register"))
          ],
        ));
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return "cannot be empty🧐";
    if (!value.contains("@")) return "not an email🧐";
    Future<bool> available = checkAvailable(value);
    bool synced = true;
    available.then((value) => synced = value);
    if (!synced) return "already taken😒";
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return "cannot be empty🧐";
    if (value.length < 8) return "two short🧐";
  }

  String? _passwordConfirmValidator(String? value) {
    if (value == null || value.isEmpty) return "cannot be empty🧐";
    if (value.length < 8) return "two short🧐";
    if (value != _passwordController.text) return "doesn't match🧐";
  }

  Future<bool> checkAvailable(String value) async {
    var client = PocketBase("http://pelerin-solutions.ru:10011");
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
    final client = PocketBase("http://pelerin-solutions.ru:10011");
    try {
      final user = await client.users.create(body: {
        'email': _emailController.text,
        'password': _passwordController.text,
        'passwordConfirm': _passwordConfirmController.text,
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

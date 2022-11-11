import 'package:flutter/material.dart';
import 'package:solution/app/pages/authpage.dart';
import 'package:solution/app/pages/homepage.dart';

import '../models/user.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User.init().then((_) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => User.isUndefined ? AuthPage() : HomePage(),
      ));
    });
    return Scaffold(body: Center(child: Icon(Icons.camera_alt_outlined)));
  }
}

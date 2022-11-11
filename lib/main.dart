import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:solution/app/pages/splashpage.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Space Mono',
          colorScheme: ColorScheme.fromSwatch(primaryColorDark: Colors.black)),
      home: SplashPage(),
    );
  }
}

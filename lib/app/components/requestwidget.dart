import 'package:flutter/material.dart';

import '../models/content.dart';
import '../pages/camerapage.dart';

class RequestWidget extends StatelessWidget {
  final Content data;
  const RequestWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CameraPage(
          content: data,
        ),
      )),
      child: ListTile(
        title: Text(data.sender),
      ),
    );
  }
}

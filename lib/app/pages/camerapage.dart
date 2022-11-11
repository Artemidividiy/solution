import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/content.dart';

class CameraPage extends StatelessWidget {
  final Content content;
  const CameraPage({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: "Sender: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            TextSpan(
                text: content.sender,
                style: const TextStyle(color: Colors.black)),
          ])),
          ElevatedButton(
              onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => (Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Your reaction will be recorded when the image will appear"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                child: Text('Continue'),
                                onPressed: null,
                              ),
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Decline"))
                            ],
                          ),
                        ],
                      ),
                    )),
                  ),
              child: Text("reply"))
        ],
      ),
    );
  }

  void reply(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (context) => Container(
              child: Column(
                children: [
                  Text(
                      "Your reaction will be recorded when the image will appear"),
                  TextButton(
                    child: Text('Continue'),
                    onPressed: null,
                  ),
                  TextButton(onPressed: null, child: Text("Decline"))
                ],
              ),
            ));
  }
}

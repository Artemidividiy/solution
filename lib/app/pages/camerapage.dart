import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/content.dart';

class CameraPage extends StatefulWidget {
  final Content content;
  const CameraPage({Key? key, required this.content}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String? dir;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sender:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // color: Colors.black
            ),
          ),
          Text(
            widget.content.sender,
            style: TextStyle(
                // color: Colors.black
                ),
          ),
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
                                onPressed: () => getReaction(context),
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
                    onPressed: () => getReaction(context),
                  ),
                  TextButton(onPressed: null, child: Text("Decline"))
                ],
              ),
            ));
  }

  void getReaction(BuildContext context) async {
    await _initDir();
    var req = await http.Client().get(Uri.parse(widget.content.data));
    var archive = ZipDecoder().decodeBytes(req.bodyBytes).first.content;
    var img = Image.memory(archive);
    showDialog(
        context: context,
        builder: (context) => Stack(
              children: [img],
            ));
  }

  Future _initDir() async {
    dir = (await getApplicationDocumentsDirectory()).path;
  }
}

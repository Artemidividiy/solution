import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:camera/camera.dart' as camera;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';

import '../models/content.dart';
import '../models/user.dart';

class CameraPage extends StatefulWidget {
  final Content content;
  const CameraPage({Key? key, required this.content}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late camera.CameraController _cameraController;
  String? dir;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
    var req = await http.Client().get(Uri.parse(widget.content.data));
    var archive = ZipDecoder().decodeBytes(req.bodyBytes).first.content;
    var img = Image.memory(archive);
    await Future.wait([_initCamera()]);
    await _cameraController.prepareForVideoRecording();
    await _cameraController.startVideoRecording();
    showDialog(
        context: context,
        builder: (context) => WillPopScope(
              onWillPop: () {
                log("no way outside");
                return Future.value(false);
              },
              child: Column(
                children: [
                  Stack(children: [
                    Container(
                      constraints: BoxConstraints.loose(Size(400, 400)),
                      alignment: Alignment.center,
                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                          ),
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: camera.CameraPreview(_cameraController))),
                    ),
                    IconButton(onPressed: send, icon: Icon(Icons.send))
                  ]),
                  // img,
                ],
              ),
            ));
  }

  Future<void> _initCamera() async {
    final cameras = await camera.availableCameras();
    _cameraController = camera.CameraController(
        cameras.firstWhere((element) =>
            element.lensDirection == camera.CameraLensDirection.front),
        camera.ResolutionPreset.max);
    await _cameraController.initialize();
  }

  void send() async {
    var video = await _cameraController.stopVideoRecording();
    File file = File("a");
    file.writeAsBytes(await video.readAsBytes());
    var encoded = ZipFileEncoder();
    var dir = await getApplicationDocumentsDirectory().toString();
    encoded.create("$dir/tmp.zip");
    await encoded.addFile(file);
    encoded.close();
    var req = http.MultipartRequest("POST", Uri.parse("127.0.0.1:8090"));
    req.files.add(await http.MultipartFile.fromPath("tmp.zip", dir));
    req.fields.addAll({
      'sender': User.id!,
      'reciever': widget.content.sender,
      'isReply': 'true',
      'replyTo': widget.content.dataID
    });
    await req.send();
    await file.delete();
  }
}

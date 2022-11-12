import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:camera/camera.dart' as camera;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:solution/app/pages/homepage.dart';
import 'package:video_player/video_player.dart';

import '../models/content.dart';
import '../models/user.dart';

enum ContentType { Image, Video }

class CameraPage extends StatefulWidget {
  final Content content;
  const CameraPage({Key? key, required this.content}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late camera.CameraController _cameraController;
  late Size size;
  String? dir;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
              style: const TextStyle(
                  // color: Colors.black
                  ),
            ),
            widget.content.sender == User.id!
                ? FutureBuilder<Widget>(
                    future: showData(ContentType.Image),
                    builder: (context, snapshot) => snapshot.connectionState ==
                            ConnectionState.done
                        ? LimitedBox(
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            maxWidth: MediaQuery.of(context).size.height * 0.7,
                            child: snapshot.data!)
                        : const CircularProgressIndicator(),
                  )
                : widget.content.isReply
                    ? FutureBuilder<Widget>(
                        future: showData(ContentType.Video),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                  ConnectionState.done
                              ? snapshot.data!
                              : const CircularProgressIndicator();
                        },
                      )
                    : ElevatedButton(
                        onPressed: () => showModalBottomSheet(
                              context: context,
                              builder: (context) => (Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: const Text(
                                          "Your reaction will be recorded when the image will appear"),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(
                                          child: const Text('Continue'),
                                          onPressed: () => getReaction(context),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Decline"))
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ),
                        child: const Text("reply"))
          ],
        ),
      ),
    );
  }

  Future<Widget> showData(ContentType ct) async {
    if (ct == ContentType.Image) {
      var req = await http.Client().get(Uri.parse(widget.content.data));
      var archive = ZipDecoder().decodeBytes(req.bodyBytes).first.content;
      return Image.memory(archive);
    }
    var _dir = await getApplicationDocumentsDirectory();
    var req = await http.Client().get(Uri.parse(widget.content.data));
    ArchiveFile archive = ZipDecoder().decodeBytes(req.bodyBytes).first;
    File f = File('${_dir.path}/tmp.mp4');
    f.writeAsBytesSync(archive.content);
    VideoPlayerController videoPlayerController = VideoPlayerController.file(f);
    await videoPlayerController.initialize();
    await videoPlayerController.setLooping(true);
    await videoPlayerController.play();
    f.delete();
    return ClipRRect(
      child: Container(
        constraints: BoxConstraints.loose(size * 0.8),
        child: Transform.scale(
          scale: videoPlayerController.value.aspectRatio / size.aspectRatio,
          child: Center(
              child: AspectRatio(
                  aspectRatio: 0.5, child: VideoPlayer(videoPlayerController))),
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
                  const Text(
                      "Your reaction will be recorded when the image will appear"),
                  TextButton(
                    child: const Text('Continue'),
                    onPressed: () => getReaction(context),
                  ),
                  const TextButton(onPressed: null, child: Text("Decline"))
                ],
              ),
            ));
  }

  void getReaction(BuildContext context) async {
    log("continue button pressed");
    var img = showData(ContentType.Image);
    await Future.wait([_initCamera()]);
    await _cameraController.prepareForVideoRecording();
    await _cameraController.startVideoRecording();
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        body: Column(children: [
          ClipRRect(
            child: Container(
              child: Transform.scale(
                scale: _cameraController.value.aspectRatio / size.aspectRatio,
                child: Center(
                  child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: camera.CameraPreview(_cameraController)),
                ),
              ),
            ),
          ),
          FutureBuilder<Widget>(
            future: showData(ContentType.Image),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return snapshot.data!;
              return const CircularProgressIndicator();
            },
          ),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            IconButton(onPressed: send, icon: const Icon(Icons.send)),
      ),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await camera.availableCameras();
    _cameraController = camera.CameraController(
        cameras.firstWhere((element) =>
            element.lensDirection == camera.CameraLensDirection.front),
        camera.ResolutionPreset.max);
    await _cameraController.initialize();
    log("camera initialized");
  }

  void send() async {
    var video = await _cameraController.stopVideoRecording();
    log("stopped recording");
    var encoded = ZipFileEncoder();
    var dir = (await getApplicationDocumentsDirectory());
    encoded.create("${dir.path}/tmp.zip");
    File file = File("${dir.path}/a.mp4");
    await file.writeAsBytes(await video.readAsBytes());
    await encoded.addFile(file);
    log("encoded");
    encoded.close();
    log("sending");
    final client = PocketBase("http://pelerin-solutions.ru:10011");
    final record = await client.records.create('content', body: {
      'sender': User.id!,
      'reciever': widget.content.sender,
      'isReply': 'true',
      'replyTo': widget.content.dataID
    }, files: [
      await http.MultipartFile.fromPath(
        "data",
        dir.path + "/tmp.zip",
      )
    ]);
    await file.delete();
    log("sent");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const HomePage(),
    ));
  }
}

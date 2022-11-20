import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class UserTile extends StatefulWidget {
  final UserModel user;
  final XFile img;
  const UserTile({Key? key, required this.user, required this.img})
      : super(key: key);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  bool isSent = false;

  pushToServer() async {
    log("encoding");
    var encoded = ZipFileEncoder();
    var dir = (await getApplicationDocumentsDirectory());
    encoded.create("${dir.path}/tmp.zip");
    File file = File("${dir.path}/a");
    await file.writeAsBytes(await widget.img.readAsBytes());
    await encoded.addFile(file);
    encoded.close();
    log("sending");
    // var req = http.MultipartRequest(
    //     "POST", Uri.parse("http://pelerin-solutions.ru:10011"))
    //   ..headers.addAll({'content-type': 'multipart/form-data'});
    // req.files.add(await http.MultipartFile.fromPath(
    //     "data", dir.path + "/tmp.zip",
    //     contentType: http_parser.MediaType("application", "zip")));

    // req.fields.addAll({
    //   'sender': User.id!,
    //   'reciever': widget.user.id,
    //   'isReply': 'false',
    //   'replyTo': 'null'
    // });
    final client = PocketBase("http://pelerin-solutions.ru:10011");
    try {
      final record = await client.records.create('content', body: {
        'sender': User.id!,
        'reciever': widget.user.id,
        'isReply': 'false',
        'replyTo': 'null'
      }, files: [
        await http.MultipartFile.fromPath(
          "data",
          dir.path + "/tmp.zip",
        )
      ]);

      // await req.send();
      log("sent");
      setState(() {
        isSent = true;
      });
    } catch (e) {
      log("pushToServer() error: ", error: e);
    }
    await file.delete();
  }

  @override
  Widget build(BuildContext context) {
    return widget.user.email != User.email
        ? GestureDetector(
            onTap: () => pushToServer(),
            child: Container(
                constraints: BoxConstraints(minHeight: 45),
                child: Flex(direction: Axis.horizontal, children: [
                  Flexible(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      child: isSent ? Icon(Icons.check) : null,
                    ),
                  ),
                  Flexible(flex: 6, child: Text(widget.user.email)),
                ])))
        : Container();
  }
}

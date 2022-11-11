import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:pocketbase/pocketbase.dart';

import 'user.dart';

class Content {
  String data;
  String dataID;
  String sender;
  String reciever;
  bool isReply;
  Content({
    required this.data,
    required this.dataID,
    required this.sender,
    required this.reciever,
    required this.isReply,
  });
  Content? replyTo;

  Content copyWith({
    String? data,
    String? sender,
    String? reciever,
    String? dataID,
    bool? isReply,
  }) {
    return Content(
      dataID: dataID ?? this.dataID,
      data: data ?? this.data,
      sender: sender ?? this.sender,
      reciever: reciever ?? this.reciever,
      isReply: isReply ?? this.isReply,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data.toString(),
      'sender': sender,
      'reciever': reciever,
      'isReply': isReply,
    };
  }

  @override
  String toString() {
    return 'Content(data: $data, sender: $sender, reciever: $reciever, isReply: $isReply)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Content &&
        other.data == data &&
        other.sender == sender &&
        other.reciever == reciever &&
        other.isReply == isReply;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        sender.hashCode ^
        reciever.hashCode ^
        isReply.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory Content.fromJson(String source) =>
      Content.fromMap(json.decode(source));

  factory Content.fromMap(RecordModel map) {
    return Content(
      dataID: map.id,
      data: "http://127.0.0.1:8090/api/files/" +
          map.collectionId.toString() +
          "/" +
          map.id +
          "/" +
          map.data['data'],
      sender: map.data['sender'] ?? '',
      reciever: map.data['reciever'] ?? '',
      isReply: map.data['isReply'] ?? false,
    );
  }
}

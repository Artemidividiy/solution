import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';

import 'user.dart';

class Content {
  Uri data;
  String sender;
  String reciever;
  bool isReply;
  Content({
    required this.data,
    required this.sender,
    required this.reciever,
    required this.isReply,
  });
  Content? replyTo;

  Content copyWith({
    Uri? data,
    String? sender,
    String? reciever,
    bool? isReply,
  }) {
    return Content(
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

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      data: Uri.parse(map['data']),
      sender: map['sender'] ?? '',
      reciever: map['reciever'] ?? '',
      isReply: map['isReply'] ?? false,
    );
  }
}

import 'dart:convert';

import 'user.dart';

class UserDto {
  String email;
  String id;
  UserDto({
    required this.email,
    required this.id,
  });

  UserDto copyWith({
    String? email,
    String? id,
  }) {
    return UserDto(
      email: email ?? this.email,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id': id,
    };
  }

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      email: map['email'] ?? '',
      id: map['id'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDto.fromJson(String source) =>
      UserDto.fromMap(json.decode(source));

  @override
  String toString() => 'UserDto(email: $email, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDto && other.email == email && other.id == id;
  }

  @override
  int get hashCode => email.hashCode ^ id.hashCode;

  factory UserDto.fromCurrentUser() =>
      UserDto(email: User.email!, id: User.id!);
}

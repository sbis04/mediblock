import 'package:flutter/material.dart';

class User {
  String uid;
  String name;

  User({
    @required this.uid,
    @required this.name,
  });

  User.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uid'] = this.uid;
    data['name'] = this.name;

    return data;
  }
}

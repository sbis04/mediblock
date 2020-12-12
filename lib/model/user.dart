import 'package:flutter/material.dart';

class User {
  String uid;
  String name;
  int waiting;

  User({
    @required this.uid,
    @required this.name,
    @required this.waiting,
  });

  User.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    waiting = json['waiting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['uid'] = this.uid;
    data['name'] = this.name;
    data['waiting'] = this.waiting;

    return data;
  }
}

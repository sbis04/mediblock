import 'package:flutter/material.dart';

class BlockFile {
  String nameEncrypted;
  String name;
  String url;
  List<String> txHashes;

  BlockFile({
    @required this.nameEncrypted,
    @required this.name,
    @required this.url,
    @required this.txHashes,
  });

  BlockFile.fromJson(Map<String, dynamic> json) {
    nameEncrypted = json['name_encr'];
    name = json['name'];
    url = json['url'];
    txHashes = json['txHashes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name_encr'] = this.nameEncrypted;
    data['name'] = this.name;
    data['url'] = this.url;
    data['txHashes'] = this.txHashes;

    return data;
  }
}

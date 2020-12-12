import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mediblock/model/block_file.dart';
import 'package:mediblock/model/user.dart';
import 'package:mediblock/utils/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  /// The main Firestore user collection
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  storeUserData({@required String userName}) async {
    DocumentReference documentReferencer = userCollection.doc(uid);

    User user = User(
      uid: uid,
      name: userName,
    );

    var data = user.toJson();

    await documentReferencer.set(data).whenComplete(() {
      print("User data added");
    }).catchError((e) => print(e));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_name', userName);
  }

  Stream<QuerySnapshot> retrieveUsers() {
    Stream<QuerySnapshot> queryUsers = userCollection
        // .where('uid', isNotEqualTo: uid)
        // .orderBy('last_seen', descending: true)
        .snapshots();

    return queryUsers;
  }

  addFileData({
    String fileNameEncrypted,
    String fileURL,
    String fileName,
    List<String> txHashes,
  }) async {
    // fileNameEncrypted -> time used for firebase upload
    // fileName -> normal name while uplaod
    DocumentReference documentReferencer =
        userCollection.doc(uid).collection('files').doc(fileNameEncrypted);

    BlockFile blockFile = BlockFile(
      nameEncrypted: fileNameEncrypted,
      name: fileName,
      url: fileURL,
      txHashes: txHashes,
    );

    var data = blockFile.toJson();

    await documentReferencer.set(data).whenComplete(() {
      print("File data added");
    }).catchError((e) => print(e));
  }

  Stream<QuerySnapshot> retriveFiles({@required String userID}) {
    Stream<QuerySnapshot> queryFiles = userCollection
        // .where('uid', isNotEqualTo: uid)
        // .orderBy('last_seen', descending: true)
        .doc(userID)
        .collection('files')
        .snapshots();

    return queryFiles;
  }
}

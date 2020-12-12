import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mediblock/model/block_file.dart';
import 'package:mediblock/model/user.dart';
import 'package:mediblock/utils/authentication.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  /// The main Firestore user collection
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  storeUserData({@required String userName}) async {
    DocumentReference documentReferencer = userCollection.doc(uid);

    User user = User(
      uid: uid,
      name: userName,
      waiting: 0,
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
        .where('uid', isNotEqualTo: uid)
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

  Stream<DocumentSnapshot> retrieveMyData() {
    Stream<DocumentSnapshot> queryMyProfile = userCollection
        // .where('uid', isNotEqualTo: uid)
        // .orderBy('last_seen', descending: true)
        .doc(uid)
        .snapshots();

    return queryMyProfile;
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

  Future<DocumentSnapshot> retrieveFile({@required String fileId}) async {
    DocumentSnapshot fileSnapshot =
        await userCollection.doc(uid).collection('files').doc(fileId).get();

    return fileSnapshot;
  }

  requestAuthorization({
    @required String otherUserId,
    @required String fileId,
    @required String fileName,
  }) async {
    DocumentReference documentReferencer = userCollection.doc(uid);

    Map<String, dynamic> incrementData = {
      'waiting': FieldValue.increment(1),
    };

    DocumentReference pendingDoc = userCollection.doc(otherUserId).collection('pending').doc(uid);

    Map<String, dynamic> pendingData = {
      'id': fileId,
      'doc_id': uid,
      'name': fileName,
    };

    await documentReferencer.update(incrementData).whenComplete(() {
      print("waiting value updated");
    }).catchError((e) => print(e));

    await pendingDoc.set(pendingData).whenComplete(() {
      print("update pending doc other");
    }).catchError((e) => print(e));
  }

  grantRequest({
    @required String docId,
    @required String fileId,
  }) async {
    DocumentReference userDoc = userCollection.doc(docId);

    Map<String, dynamic> decrementData = {
      'waiting': FieldValue.increment(-1),
    };

    DocumentReference pendingDoc = userCollection.doc(uid).collection('pending').doc(docId);

    DocumentReference doneDoc = userCollection.doc(uid).collection('done').doc(docId);

    Map<String, dynamic> doneData = {'uid': docId};

    DocumentReference grantedDoc = userCollection.doc(docId).collection('granted').doc(fileId);

    DocumentSnapshot retrievedFile = await retrieveFile(fileId: fileId);

    await doneDoc.set(doneData).whenComplete(() {
      print("done doc added");
    }).catchError((e) => print(e));

    await grantedDoc.set(retrievedFile.data()).whenComplete(() {
      print("granted doc added");
    }).catchError((e) => print(e));

    await pendingDoc.delete().whenComplete(() {
      print('pending doc deleted: $docId');
    }).catchError((e) => print(e));

    await userDoc.update(decrementData).whenComplete(() {
      print("waiting value updated");
    }).catchError((e) => print(e));
  }

  Stream<QuerySnapshot> retrievePendingRequests() {
    Stream<QuerySnapshot> queryPendingRequests = userCollection
        // .where('uid', isNotEqualTo: uid)
        // .orderBy('last_seen', descending: true)
        .doc(uid)
        .collection('pending')
        .snapshots();

    return queryPendingRequests;
  }

  Stream<QuerySnapshot> retrieveGrantedRequests() {
    Stream<QuerySnapshot> queryGrantedRequests = userCollection
        // .where('uid', isNotEqualTo: uid)
        // .orderBy('last_seen', descending: true)
        .doc(uid)
        .collection('granted')
        .snapshots();

    return queryGrantedRequests;
  }

  Future<bool> checkIfAuthorized({@required String otherId}) async {
    DocumentSnapshot doneDocSnapshot =
        await userCollection.doc(uid).collection('done').doc(otherId).get();

    return doneDocSnapshot?.exists ?? false;
  }

  Future<String> downloadFile({@required String fileName, @required fileId}) async {
    Directory externalStorageDir = await getExternalStorageDirectory();
    Directory localPath = Directory('${externalStorageDir.path}');

    String localPathString;

    if (await localPath.exists()) {
      print('Exists');
      localPathString = localPath.path;
    } else {
      print('Creating');
      // If folder does not exists create folder and then return its path
      final Directory _directoryNewFolder = await externalStorageDir.create(recursive: true);
      localPathString = _directoryNewFolder.path;
    }

    File downloadToFile = File('$localPathString/$fileName');

    try {
      await FirebaseStorage.instance
          .ref('files/$fileId.${fileName.split('.').last}')
          .writeToFile(downloadToFile);
    } on FirebaseException catch (e) {
      print(e);
    }

    return downloadToFile.path;
  }
}

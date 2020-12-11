import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mediblock/model/address.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/sample/sample_data.dart';
import 'package:mediblock/utils/block_connector.dart';
import 'package:mediblock/utils/database.dart';
import 'package:mediblock/utils/file_selector.dart';
import 'package:web3dart/web3dart.dart';

class UploadPage extends StatefulWidget {
  final String userName;

  const UploadPage({@required this.userName});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final Database _database = Database();
  final FileSelector _fileSelector = FileSelector();
  final BlockConnector blockConnector = BlockConnector();
  final Reference _storageReference = FirebaseStorage.instance.ref();

  bool _isUploading = false;
  bool _checkIfValidString = false;
  String currentTimeString;

  FilePickerResult _selectedFile;

  List<String> _uploadProgressPhases = [
    'loading file',
    'encrypting file',
    'uploading to blockchain',
    'uploading file',
    'finalizing',
  ];

  int _currentUploadProgressPhase = 0;

  double _fileUploadProgressFraction = 0.0;

  int totalTx = 0;
  int currentTx = 0;
  int processedTx = 0;

  int totalDataToRetrieve = 0;
  int totalDataProcessed = 0;

  bool retrievingTx = false;
  bool processingTx = false;

  List<String> hashList = [];
  String jsonAddress;

  TextEditingController _textControllerPassphrase = TextEditingController();
  FocusNode _textFocusNodePassphrase = FocusNode();

  String _validateString(String value) {
    value = value.trim();

    if (_textControllerPassphrase.text != null) {
      if (value.isEmpty) {
        return 'Passphrase can\'t be empty';
      }
    }

    return null;
  }

  Future<void> _processTransaction(List<BigInt> matrixData) async {
    const int TX_SIZE = 400;
    final int totalMatrixLength = matrixData.length;

    setState(() {
      totalTx = totalMatrixLength ~/ TX_SIZE;
    });

    if (totalMatrixLength % TX_SIZE != 0) totalTx++;

    currentTx = 0;
    processedTx = 0;

    String txHash;

    int start = 0;
    int end = TX_SIZE;

    hashList.clear();

    setState(() {
      processingTx = true;
    });

    while (processedTx != totalTx) {
      if (processedTx == currentTx) {
        currentTx++;
        List<BigInt> listSegment = matrixData.sublist(start, end);
        print('start: $start, end: $end, list: $listSegment');
        txHash = await blockConnector.sendData(listSegment);
        hashList.add(txHash);
      }

      await Future.delayed(Duration(seconds: 6));

      TransactionReceipt receipt = await blockConnector.getTransactionReceipt(txHash);
      if (receipt != null) {
        // print('Trnx hash: ${blockConnector.information.hash}, ');
        print('Receipt: Cumulitive gas used: ${receipt.cumulativeGasUsed} wei, ');
        print('Receipt: Gas used: ${receipt.gasUsed} wei, ');
        print('Receipt: Status: ${receipt.status}');

        setState(() {
          processedTx++;
        });

        start += TX_SIZE;
        end += TX_SIZE;
      }

      print('Transactions: $processedTx/$totalTx, currently processing: $currentTx');
    }
    setState(() {
      processingTx = false;
    });

    blockConnector.getWalletBalance();

    Address address = Address(
      hashes: hashList,
      count: hashList.length,
      length: TX_SIZE,
    );

    jsonAddress = jsonEncode(address);

    // Writing the addresses to a file for testing
    // final result = File('address/address.json').openWrite(mode: FileMode.write);
    // result.write(JsonEncoder.withIndent('  ').convert(jsonAddress));
    // await result.close();

    // setState(() {
    //   hashListTextController.text = jsonAddress;
    // });

    setState(() {});

    print('JSON: $jsonAddress');

    print('--------------');
    print('TxHASH LIST:');
    print(hashList);
  }

  Future<List<int>> _retrieveData() async {
    // here goes the firebase stored map
    // in form of the model structure
    // of Address
    Map<String, dynamic> decodedJson = jsonDecode(jsonAddress);

    // Address address = Address.fromJson(decodedJson);

    List<int> fullData = [];

    List<dynamic> hashList = decodedJson['hash'];

    setState(() {
      totalDataToRetrieve = hashList.length;
      totalDataProcessed = 0;
    });

    for (String hash in hashList) {
      TransactionInformation txInfo = await blockConnector.getTransactionDetails(hash);
      List<int> cleanedData = blockConnector.sanitizeData(txInfo.input);
      fullData.addAll(cleanedData);
      totalDataProcessed++;
    }

    return fullData;
  }

  Future<String> uploadFile(File document, String format) async {
    Reference ref = _storageReference.child('files/');

    setState(() {
      currentTimeString = DateTime.now().millisecondsSinceEpoch.toString();
    });

    final UploadTask storageUploadTask = ref.child('$currentTimeString.$format').putFile(document);

    storageUploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _fileUploadProgressFraction = snapshot.bytesTransferred / snapshot.totalBytes;
      });

      print('Task state: ${snapshot.state}');
      print('Progress: ${_fileUploadProgressFraction * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(storageUploadTask.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await storageUploadTask;
      print('Upload complete.');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }

    final TaskSnapshot downloadUrl = await storageUploadTask;

    final String url = (await downloadUrl.ref.getDownloadURL());

    print("File URL " + url);
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _validateString(_textControllerPassphrase.text);
        });
        _textFocusNodePassphrase.unfocus();
      },
      child: Scaffold(
        backgroundColor: CustomColors.dark,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CustomColors.dark,
          title: Text(
            'Upload',
            style: TextStyle(
              color: CustomColors.blue,
              fontSize: 26,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'uploader: ',
                      style: TextStyle(color: CustomColors.yellow, fontSize: 18),
                    ),
                    Text(
                      '${widget.userName}',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 20.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: _selectedFile != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                      color: CustomColors.shade.withOpacity(0.8), width: 3),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 60,
                                        color: CustomColors.blue,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  _selectedFile.files[0].name,
                                                  style: TextStyle(
                                                      color: CustomColors.yellow, fontSize: 18.0),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Text(
                                                  'size: ',
                                                  style: TextStyle(
                                                      color: CustomColors.shade, fontSize: 14.0),
                                                ),
                                                Text(
                                                  '${_selectedFile.files[0].size} KB',
                                                  style: TextStyle(
                                                      color: CustomColors.yellow, fontSize: 14.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            onTap: () async {
                              await _fileSelector.chooseFile().then((value) {
                                setState(() {
                                  _selectedFile = value;
                                });
                              });
                            },
                            child: Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(color: CustomColors.shade, width: 3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Click here\nto select a document',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 32.0,
                                        color: CustomColors.shade.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: 30.0),
                                    Icon(
                                      Icons.add_circle,
                                      color: CustomColors.shade,
                                      size: 80,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Visibility(
                  visible: _selectedFile != null,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 30.0),
                    child: TextField(
                      enabled: !_isUploading,
                      controller: _textControllerPassphrase,
                      focusNode: _textFocusNodePassphrase,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      cursorColor: CustomColors.blue,
                      autofocus: false,
                      // onChanged: (value) {
                      //   setState(() {
                      //     _passphrase = value;
                      //   });
                      // },
                      onSubmitted: (value) {
                        setState(() {
                          _validateString(value);
                        });
                        _textFocusNodePassphrase.unfocus();
                      },
                      style: TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: CustomColors.blue,
                            width: 3,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: CustomColors.blue.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: CustomColors.blue,
                            width: 3,
                          ),
                        ),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Colors.white70,
                        ),
                        hintText: "Type your passphase",
                        fillColor: Colors.white10,
                        errorText: _checkIfValidString
                            ? _validateString(_textControllerPassphrase.text)
                            : null,
                        errorStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _isUploading,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 0.0,
                      bottom: 30.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          backgroundColor: Colors.white12,
                          // the value of the progress (b/t: 0.0 - 1.0),
                          // setting to null turns to infinite
                          value: (_fileUploadProgressFraction +
                                  (totalTx == 0 ? 0 : processedTx / totalTx)) /
                              2,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            CustomColors.blue,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '${_uploadProgressPhases[_currentUploadProgressPhase]} (${(((_fileUploadProgressFraction + (totalTx == 0 ? 0 : processedTx / totalTx)) / 2) * 100).toStringAsFixed(0)}%) . . .',
                          style: TextStyle(
                            color: CustomColors.blue,
                            letterSpacing: 2,
                            fontSize: 14.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  child: RaisedButton(
                    color: CustomColors.blue,
                    onPressed: _isUploading
                        ? null
                        : () async {
                            setState(() {
                              _currentUploadProgressPhase = 0;
                              _checkIfValidString = true;
                            });
                            if (_validateString(_textControllerPassphrase.text) == null) {
                              blockConnector.initializeClient();
                              setState(() {
                                _isUploading = true;
                                _currentUploadProgressPhase = 2;
                              });
                              blockConnector.initializeClient();
                              await _processTransaction(SampleData.sampleMatrix);
                              setState(() {
                                _isUploading = true;
                                _currentUploadProgressPhase = 3;
                              });
                              String fileURL = await uploadFile(
                                File(_selectedFile.files.single.path),
                                _selectedFile.files.single.extension,
                              );
                              setState(() {
                                _currentUploadProgressPhase = 4;
                                _isUploading = false;
                              });
                              await _database.addFileData(
                                fileNameEncrypted: currentTimeString,
                                fileName: _selectedFile.files.single.name,
                                fileURL: fileURL,
                                txHashes: hashList,
                              );
                            }
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Text(
                        'UPLOAD',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isUploading ? Colors.white54 : Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

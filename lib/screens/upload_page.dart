import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/utils/database.dart';
import 'package:mediblock/utils/file_selector.dart';

class UploadPage extends StatefulWidget {
  final String userName;

  const UploadPage({@required this.userName});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  FileSelector _fileSelector = FileSelector();
  Database _database = Database();

  bool _isUploading = false;
  bool _checkIfValidString = false;
  FilePickerResult _selectedFile;

  List<String> _uploadProgressPhases = [
    'loading file',
    'encrypting file',
    'uploading to blockchain',
    'uploading file',
    'finalizing',
  ];

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                          value: null,
                          valueColor: new AlwaysStoppedAnimation<Color>(
                            CustomColors.blue,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          '${_uploadProgressPhases[1]} . . .',
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
                              _checkIfValidString = true;
                            });
                            if (_validateString(_textControllerPassphrase.text) == null) {
                              setState(() {
                                _isUploading = true;
                              });
                              await _database.uploadFile(
                                File(_selectedFile.files.single.path),
                                _selectedFile.files.single.extension,
                              );
                              setState(() {
                                _isUploading = false;
                              });
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

import 'package:flutter/material.dart';
import 'package:mediblock/model/block_file.dart';
import 'package:mediblock/model/user.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/utils/database.dart';

class OtherUserPage extends StatefulWidget {
  final User user;

  const OtherUserPage({@required this.user});

  @override
  _OtherUserPageState createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  Database _database = Database();

  bool _sendingAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.dark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.dark,
        title: Text(
          '${widget.user.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: StreamBuilder(
            stream: _database.retriveFiles(userID: widget.user.uid),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    BlockFile fileData = BlockFile.fromJson(snapshot.data.documents[index].data());

                    return Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: CustomColors.shade.withOpacity(0.8), width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                        fileData.name,
                                        style: TextStyle(
                                          color: CustomColors.yellow,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5.0),
                                  _sendingAuth
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            width: 200,
                                            child: LinearProgressIndicator(
                                              backgroundColor: Colors.white12,
                                              valueColor: new AlwaysStoppedAnimation<Color>(
                                                CustomColors.shade,
                                              ),
                                            ),
                                          ),
                                        )
                                      : RaisedButton(
                                          onPressed: () async {
                                            setState(() {
                                              _sendingAuth = true;
                                            });
                                            await _database.requestAuthorization(
                                              otherUserId: widget.user.uid,
                                              fileId: fileData.nameEncrypted,
                                              fileName: fileData.name,
                                            );
                                            setState(() {
                                              _sendingAuth = false;
                                            });
                                          },
                                          color: CustomColors.shade,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Request authorization',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: CustomColors.brown,
                                              letterSpacing: 1.4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    CustomColors.blue,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

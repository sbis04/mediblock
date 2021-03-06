import 'package:flutter/material.dart';
import 'package:mediblock/model/user.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/screens/authorized_files_page.dart';
import 'package:mediblock/screens/files_page.dart';
import 'package:mediblock/screens/other_user_page.dart';
import 'package:mediblock/screens/upload_page.dart';
import 'package:mediblock/utils/database.dart';
import 'package:mediblock/widgets/logo_widget.dart';

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({@required this.userName});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Database database = Database();

  bool _isGrantingRequest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.dark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.dark,
        title: LogoWidget(textSize: 26),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: CustomColors.blue,
              child: IconButton(
                icon: Text(
                  widget.userName.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors.shade,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UploadPage(userName: widget.userName),
            ),
          );
        },
        child: Icon(
          Icons.file_upload,
          color: CustomColors.brown,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Files',
                      style: TextStyle(
                        color: CustomColors.shade,
                        fontSize: 20.0,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FilesPage(),
                          ),
                        );
                      },
                      color: CustomColors.shade,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: CustomColors.brown,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  'The files that you have uploaded are present here',
                  style: TextStyle(
                    color: CustomColors.shade,
                    fontSize: 12.0,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              StreamBuilder(
                stream: database.retrieveGrantedRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.documents.length > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          // width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2.0,
                              color: Colors.lightGreen.withOpacity(0.8),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Authorized files',
                                  style: TextStyle(
                                    color: Colors.lightGreen,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AuthorizedFilesPage(),
                                      ),
                                    );
                                  },
                                  color: Colors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                    child: Text(
                                      'SHOW',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: CustomColors.brown,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }
                  return Container();
                },
              ),
              StreamBuilder(
                stream: database.retrieveMyData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int waitingCount = snapshot.data['waiting'];
                    if (waitingCount > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          // width: double.maxFinite,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 3.0,
                              color: CustomColors.yellow.withOpacity(0.8),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Pending request',
                                  style: TextStyle(
                                    color: CustomColors.yellow,
                                    fontSize: 16.0,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 16.0,
                                  backgroundColor: CustomColors.yellow,
                                  child: Text(
                                    '$waitingCount',
                                    style: TextStyle(
                                      color: CustomColors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }

                  return Container();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: Container(
                  height: 1,
                  width: double.maxFinite,
                  color: Colors.white54,
                ),
              ),
              StreamBuilder(
                stream: database.retrievePendingRequests(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.documents.length > 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, index) {
                            Map<String, dynamic> pendingRequestInfo =
                                snapshot.data.documents[index].data();

                            String fileName = pendingRequestInfo['name'];
                            String fileId = pendingRequestInfo['id'];
                            String docId = pendingRequestInfo['doc_id'];

                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 3.0,
                                  color: CustomColors.blue.withOpacity(0.8),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 4.0, bottom: 4.0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                  horizontalTitleGap: 0,
                                  // leading: CircleAvatar(
                                  //   radius: 20,
                                  //   backgroundColor: CustomColors.blue,
                                  //   child: IconButton(
                                  //     icon: Text(
                                  //       'M',
                                  //       style: TextStyle(
                                  //         color: Colors.white,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //     onPressed: () {},
                                  //   ),
                                  // ),
                                  title: Row(
                                    children: [
                                      Text(
                                        'file: ',
                                        style: TextStyle(
                                          color: CustomColors.yellow,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$fileName',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: _isGrantingRequest
                                      ? CircularProgressIndicator(
                                          valueColor: new AlwaysStoppedAnimation<Color>(
                                            Colors.green,
                                          ),
                                        )
                                      : RaisedButton(
                                          onPressed: () async {
                                            setState(() {
                                              _isGrantingRequest = true;
                                            });
                                            await database.grantRequest(
                                                docId: docId, fileId: fileId);
                                            setState(() {
                                              _isGrantingRequest = false;
                                            });
                                          },
                                          color: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                            child: Text(
                                              'GRANT',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.white,
                                                letterSpacing: 2,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(height: 8),
                        ),
                      );
                    }
                    return Container();
                  }
                  return Container();
                },
              ),
              Text(
                'USERS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14.0,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.0),
              StreamBuilder(
                stream: database.retrieveUsers(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (_, index) {
                        User userData = User.fromJson(snapshot.data.documents[index].data());
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OtherUserPage(user: userData),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3.0,
                                color: CustomColors.blue.withOpacity(0.8),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 0),
                              horizontalTitleGap: 0,
                              // leading: CircleAvatar(
                              //   radius: 20,
                              //   backgroundColor: CustomColors.blue,
                              //   child: IconButton(
                              //     icon: Text(
                              //       'M',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     onPressed: () {},
                              //   ),
                              // ),
                              title: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  userData.name,
                                  // textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: '',
                                    fontSize: 26.0,
                                  ),
                                ),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: FutureBuilder(
                                    future: database.checkIfAuthorized(otherId: userData.uid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        bool isAuthorized = snapshot.data;
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              isAuthorized ? 'authorized' : 'not authorized',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isAuthorized
                                                    ? Colors.lightGreen
                                                    : CustomColors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: isAuthorized
                                                  ? Colors.lightGreen
                                                  : CustomColors.red,
                                            ),
                                          ],
                                        );
                                      }
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'not authorized',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: CustomColors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.circle,
                                            size: 10,
                                            color: CustomColors.red,
                                          ),
                                        ],
                                      );
                                    }),
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mediblock/model/user.dart';
import 'package:mediblock/res/custom_colors.dart';
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
          child: StreamBuilder(
            stream: database.retrieveUsers(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    User userData = User.fromJson(snapshot.data.documents[index].data());
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 3.0, color: CustomColors.blue.withOpacity(0.8)),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'not authorized',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CustomColors.red,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: CustomColors.red,
                              ),
                            ],
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
        ),
      ),
    );
  }
}

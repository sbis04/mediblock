import 'package:flutter/material.dart';
import 'package:mediblock/model/block_file.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/utils/block_connector.dart';
import 'package:mediblock/utils/database.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web3dart/web3dart.dart';

class AuthorizedFilesPage extends StatefulWidget {
  @override
  _AuthorizedFilesPageState createState() => _AuthorizedFilesPageState();
}

class _AuthorizedFilesPageState extends State<AuthorizedFilesPage> {
  final Database _database = Database();
  final BlockConnector blockConnector = BlockConnector();

  bool _downloading = false;

  int totalDataToRetrieve = 0;
  int totalDataProcessed = 0;

  int _currentDownloadProgressPhase = 0;

  double _fileDownloadProgressFraction = 0.0;

  List<String> _downloadProgressPhases = [
    'decrypting file',
    'downloading file',
    'finalizing',
  ];

  Future<List<int>> _retrieveData(List<dynamic> txHashList) async {
    // here goes the firebase stored map
    // in form of the model structure
    // of Address
    // Map<String, dynamic> decodedJson = jsonDecode(jsonAddress);

    // Address address = Address.fromJson(decodedJson);

    List<int> fullData = [];

    // List<dynamic> hashList = txHashList;

    setState(() {
      totalDataToRetrieve = txHashList.length;
      totalDataProcessed = 0;
    });

    for (String hash in txHashList) {
      TransactionInformation txInfo = await blockConnector.getTransactionDetails(hash);
      List<int> cleanedData = blockConnector.sanitizeData(txInfo.input);
      fullData.addAll(cleanedData);
      totalDataProcessed++;
    }
    print('---------------------');
    print('RETRIEVED DATA:');
    print(fullData);

    return fullData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.dark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.dark,
        title: Text(
          'Authorized files',
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
            stream: _database.retrieveGrantedRequests(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    BlockFile fileData = BlockFile.fromJson(snapshot.data.documents[index].data());
                    print(fileData.txHashes);
                    return Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: CustomColors.shade.withOpacity(0.8), width: 3),
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
                                  _downloading
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Container(
                                                width: 200,
                                                child: LinearProgressIndicator(
                                                  backgroundColor: Colors.white12,
                                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                                    CustomColors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              '${_downloadProgressPhases[_currentDownloadProgressPhase]} (${(((_fileDownloadProgressFraction + (totalDataToRetrieve == 0 ? 0 : totalDataProcessed / totalDataToRetrieve)) / 2) * 100).toStringAsFixed(0)}%) ...',
                                              style: TextStyle(
                                                color: CustomColors.blue,
                                                letterSpacing: 1.2,
                                                fontSize: 12.0,
                                              ),
                                            )
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'encrypted',
                                              style: TextStyle(
                                                color: CustomColors.red,
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 5.0),
                                            Icon(
                                              Icons.lock,
                                              color: CustomColors.red,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        _downloading = true;
                                        _currentDownloadProgressPhase = 0;
                                      });
                                      await Permission.storage.request();
                                      blockConnector.initializeClient();
                                      await _retrieveData(fileData.txHashes);
                                      // await FlutterDownloader.initialize(debug: true);
                                      setState(() {
                                        _currentDownloadProgressPhase = 1;
                                      });

                                      String filePath = await _database.downloadFile(
                                          fileName: fileData.name, fileId: fileData.nameEncrypted);

                                      setState(() {
                                        _downloading = false;
                                      });

                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: CustomColors.dark,
                                            title: Text(
                                              'Download complete',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            content: Text(
                                              'Do you want to open the file?',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              RaisedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  await OpenFile.open(filePath);
                                                },
                                                color: CustomColors.shade,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                  child: Text(
                                                    'OPEN',
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
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.cloud_download,
                                      size: 32.0,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                ),
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

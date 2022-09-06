import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_check/common.dart';
import 'package:flutter_app_check/dashboard.dart';
import 'package:flutter_app_check/fileUploadModel.dart';
import 'package:flutter_app_check/httpService.dart';
import 'package:flutter_app_check/uploadListModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:splashscreen/splashscreen.dart';


class Upload extends StatefulWidget {
  String lastUpdated;
  Upload(this.lastUpdated);
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  var dio = Dio();
  String ipAddress;
  String todate = DateTime.now().toString();


  void initState() {
    // TODO: implement initState
    super.initState();



  }



  Future download2(Dio dio, String url, String savePath) async {
    try {
      Common.saveSharedPref("lastUpdated", todate);
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        Dashboard('aa', false, 'bb', 'aa')),
                    (Route<dynamic> route) => false),
          ),
          title: const Text('Upload'),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: size.height,
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(115, 197, 237, 1),
                      Color.fromRGBO(58, 177, 158, 1)
                    ])),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),


                        child: Column(
                          children: <Widget>[

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Last Modified on : ',
                                          style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red)),
                                      SizedBox(height: 5,),

                                      Text(widget.lastUpdated,
                                          style: TextStyle(fontSize: 12,color: Colors.green,fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),


                              ],
                            ),
                            //&&  listData.data.isPositionSet=='Y'
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                              child: RaisedButton(
                                onPressed: () async {
                                  ipAddress = await Common.getSharedPref("ipAddress");
                                  var statusPermission = await Permission.storage.status;

                                  if (!statusPermission.isGranted) {
                                    await Permission.storage.request();
                                  }
                                  final tempDir =
                                  await DownloadsPathProvider.downloadsDirectory;
                                  String tempPath = tempDir.path;
                                  final path = tempPath + '/hisan';
                                  bool directoryExists = await Directory(path).exists();

                                  if (directoryExists) {
                                    print('Exist');

                                    final newPath = path;
                                    String fileName = 'data.csv';
                                    String fullPath = "$newPath/" + fileName;
                                    print('full path ${fullPath}');
                                    final fileUrl = ipAddress+'/data.csv';
                                    download2(dio, fileUrl, fullPath);
                                  } else {
                                    print('Not Exist');
                                    final newPath =
                                    await Directory(path).create(recursive: true);
                                    print(newPath);
                                    String fileName = 'data.csv';
                                    String fullPath = "$newPath/" + fileName;
                                    print('full path ${fullPath}');
                                    final fileUrl = ipAddress+'/data.csv';

                                    download2(dio, fileUrl, fullPath);
                                  }
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Dashboard('aa', false, 'bb', 'aa')),
                                          (Route<dynamic> route) => false);

                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                textColor: Colors.white,
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50.0,
                                  width: size.width * 0.5,
                                  decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.circular(80.0),
                                      color: Colors.white),
                                  padding: const EdgeInsets.all(0),
                                  child: Text(
                                    "Download",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ),
                              ),
                            ),




                          ],
                        ),
                      ),
                    ],
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

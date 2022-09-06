import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_check/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dashboard.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var dio = Dio();
  TextEditingController barcodeIndex = new TextEditingController(text: '0');
  TextEditingController itemNameIndex = new TextEditingController(text: '1');
  TextEditingController mrpIndex = new TextEditingController(text: '2');
  TextEditingController salPrice = new TextEditingController(text: '3');
  TextEditingController brand = new TextEditingController(text: '4');
  TextEditingController companyName = new TextEditingController();
  TextEditingController section = new TextEditingController();
  TextEditingController ipAddress = new TextEditingController();
  TextEditingController barcodeDigit = new TextEditingController(text: '5');

  String endDate;
  bool ltr=false;
  bool nos=false;
  bool kg=false;
  bool m= false;
  var ltr1;
  var nos1;
  var kg1;
  var m1;
  String qtyType='';
  String todate = DateTime.now().toString();

  @override
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

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          //actions: <Widget>[_NomalPopMenu()],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(115, 197, 237, 1),
                  Color.fromRGBO(58, 177, 158, 1)
                ])),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "Barcode Position",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: barcodeIndex,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "Item Name Position",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: itemNameIndex,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "MRP Position",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: mrpIndex,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "Sale Price Position",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: salPrice,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "Brand Position",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: brand,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 21),
                            child: Text(
                              "Section",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 5),
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: MediaQuery.of(context).size.height * 0.06,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: TextField(
                                  maxLines: 1,
                                  controller: section,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 21),
                  child: Text(
                    "Company Name",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextField(
                        maxLines: 1,
                        controller: companyName,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 21),
                  child: Text(
                    "End Date",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: DateTimePicker(
                        decoration: InputDecoration(
                          border: InputBorder.none,

                        ),
                        initialValue: endDate,

                        // initialValue or controller.text can be null, empty or a DateTime string otherwise it will throw an error.
                        type: DateTimePickerType.date,

                        //controller: fromDate,
                        firstDate: DateTime(1995),
                        lastDate: DateTime.now()
                            .add(Duration(days: 365)),
                        // This will add one year from current date
                        validator: (value) {
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              endDate = value;
                            });
                          }
                        },
                        // We can also use onSaved
                        onSaved: (value) {
                          if (value.isNotEmpty) {
                            endDate = value;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 21),
                  child: Text(
                    "Type",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: ltr,
                            onChanged: (bool value) {
                              setState(() {
                                ltr = value;
                                if(value==true) {
                                  ltr1 = 'Ltr.';
                                }
                                else
                                {
                                  ltr1 = '';
                                }
                              });
                            },
                          ),
                          Text('Ltr'),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: nos,
                            onChanged: (bool value) {
                              setState(() {
                                nos = value;
                                if(value==true) {
                                  nos1='Nos.';
                                }
                                else
                                {
                                  nos1 = '';
                                }

                              });
                            },
                          ),
                          Text('Nos'),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: kg,
                            onChanged: (bool value) {
                              setState(() {
                                kg = value;
                                if(value==true) {
                                  kg1='Kg.';
                                }
                                else
                                {
                                  kg1 = '';
                                }

                              });
                            },
                          ),
                          Text('Kg'),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: m,
                            onChanged: (bool value) {
                              setState(() {
                                m = value;
                                if(value==true) {
                                  m1='M.';
                                }
                                else
                                {
                                  m1 = '';
                                }

                              });
                            },
                          ),
                          Text('M'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 21),
                  child: Text(
                    "Ip Address",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextField(
                        maxLines: 1,
                        controller: ipAddress,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 21),
                  child: Text(
                    "Barcode Digit",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextField(
                        maxLines: 1,
                        controller: barcodeDigit,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: RaisedButton(
                    onPressed: () async {
                      if (barcodeIndex.text.isEmpty) {
                        Common.toastMessaage(
                            'Barcode Position cannot be empty', Colors.red);
                      } else if (itemNameIndex.text.isEmpty) {
                        Common.toastMessaage(
                            'Item Name Position cannot be empty', Colors.red);
                      } else if (mrpIndex.text.isEmpty) {
                        Common.toastMessaage(
                            'MRP Position cannot be empty', Colors.red);
                      } else if (salPrice.text.isEmpty) {
                        Common.toastMessaage(
                            'Sale Price Position cannot be empty', Colors.red);
                      } else if (brand.text.isEmpty) {
                        Common.toastMessaage(
                            'Brand Name Position cannot be empty', Colors.red);
                      } else if (companyName.text.isEmpty) {
                        Common.toastMessaage(
                            'Company  Name  cannot be empty',
                            Colors.red);
                      }
                      else if (endDate==null) {
                        Common.toastMessaage(
                            'End Date cannot be empty',
                            Colors.red);
                      }
                      else if (ipAddress.text.isEmpty) {
                        Common.toastMessaage(
                            'Ip Address cannot be empty',
                            Colors.red);
                      }
                      else if (barcodeDigit.text.isEmpty) {
                        Common.toastMessaage(
                            'Barcode Digit cannot be empty',
                            Colors.red);
                      }
                      else {
                        Common.saveSharedPref(
                            "barcodePosition", barcodeIndex.text);
                        Common.saveSharedPref(
                            "itemNamePosition", itemNameIndex.text);
                        Common.saveSharedPref("brandPosition", brand.text);
                        Common.saveSharedPref(
                            "salesPricePosition", salPrice.text);
                        Common.saveSharedPref("mrpPosition", mrpIndex.text);
                        Common.saveSharedPref("companyName", companyName.text);

                        Common.saveSharedPref("endDate", endDate);
                        Common.saveSharedPref("settings", 'Completed');
                        Common.saveSharedPref("section", section.text);
                        Common.saveSharedPref("ipAddress", ipAddress.text);
                        Common.saveSharedPref("barcodeDigit", barcodeDigit.text);
                        qtyType='';
                        if(ltr==true)
                          qtyType=qtyType+ltr1;
                        if(nos==true)
                          qtyType=qtyType+nos1;
                        if(kg==true)
                          qtyType=qtyType+kg1;
                        if(m==true)
                          qtyType=qtyType+m1;
                        Common.saveSharedPref("productType", qtyType);
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
                          final fileUrl = ipAddress.text+'/data.csv';
                          download2(dio, fileUrl, fullPath);
                        } else {
                          print('Not Exist');
                          final newPath =
                              await Directory(path).create(recursive: true);
                          print(newPath);
                          String fileName = 'data.csv';
                          String fullPath = "$newPath/" + fileName;
                          print('full path ${fullPath}');
                          final fileUrl = ipAddress.text+'/data.csv';

                          download2(dio, fileUrl, fullPath);
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    Dashboard('aa', false, 'bb', 'aa')),
                            (Route<dynamic> route) => false);
                      }
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
                        "Save",
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
        ));
  }
}

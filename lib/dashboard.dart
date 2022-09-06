import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_check/DashboardModel.dart';
import 'package:flutter_app_check/common.dart';
import 'package:flutter_app_check/connection.dart';
import 'package:flutter_app_check/httpService.dart';
import 'package:flutter_app_check/login.dart';
import 'package:flutter_app_check/productDetailsModel.dart';
import 'package:flutter_app_check/settings.dart';
import 'package:flutter_app_check/testprint.dart';
import 'package:flutter_app_check/upload.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class Dashboard extends StatefulWidget {
  String token;
  bool connection;
  String type;
  String serialNumber;

  Dashboard(this.token, this.connection, this.type, this.serialNumber);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardModel dashboardDetails;
  bool _isConnected;
  TextEditingController barcodeText = new TextEditingController();
  TextEditingController itemName = new TextEditingController();
  TextEditingController sellingCost = new TextEditingController();
  TextEditingController mrp = new TextEditingController();
  TextEditingController qty = new TextEditingController();
  TextEditingController brand = new TextEditingController();
  TextEditingController totalCost = new TextEditingController();
  TextEditingController employeeId = new TextEditingController();
  TextEditingController search = new TextEditingController();
  ProductDetailsModel details;
  bool status = false;

  double totalPrice = 0;
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  String pathImage;
  TestPrint testPrint;
  int _value = 0;
  String _scanBarcode;
  bool searchSts = false;
  String companyName;
  String qtyType;
  String section;
  String lastUpdate;
  String barcodeDigit;

  @override
  void initState() {
    _connected = widget.connection;
    super.initState();
    initPlatformState();
    _checkInternetConnection();
    testPrint = TestPrint();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      companyName = await Common.getSharedPref("companyName");
      qtyType = await Common.getSharedPref("productType");
      section = await Common.getSharedPref("section");
      lastUpdate = await Common.getSharedPref("lastUpdated");
      barcodeDigit = await Common.getSharedPref("barcodeDigit");

      if (response.isNotEmpty) {
        setState(() {
          _isConnected = true;
          //getDataDashboard();
        });
      }
    } on SocketException catch (err) {
      setState(() {
        _isConnected = false;
      });
      if (kDebugMode) {
        print(err);
      }
    }
  }
  Future<void> initPlatformState() async {
    bool isConnected = await bluetooth.isConnected;
    print(isConnected);
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
      print(devices);
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() async {
            _connected = false;
            print("bluetooth device state: bluetooth off");
            await Permission.bluetooth.request();
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      Common.showProgressDialog(context, "Loading..");

      _scanBarcode = barcodeScanRes;
      getData(barcodeScanRes);
    });
  }

  getData(searchData) async {
    print(searchData);
    if (searchData != null) {
      Navigator.pop(context);
    }
    var statusPermission = await Permission.storage.status;
    if (!statusPermission.isGranted) {
      await Permission.storage.request();
    }

    final tempDir = await DownloadsPathProvider.downloadsDirectory;
    String fileName = 'data.csv';
    String barcodePosition = await Common.getSharedPref("barcodePosition");
    ;
    String itemNamePosition = await Common.getSharedPref("itemNamePosition");
    ;
    String salesPricePosition =
        await Common.getSharedPref("salesPricePosition");
    ;
    String mrpPosition = await Common.getSharedPref("mrpPosition");
    ;
    String brandPosition = await Common.getSharedPref("brandPosition");
    ;
    String tempPath = tempDir.path;
    var filePath = tempPath + '/hisan/' + fileName;
    print(filePath);

    final input = new File(filePath).openRead();

    final fields = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();

    setState(() {
      searchSts = false;

      for (var i = 1; i < fields.length; i++) {
        if (fields[i][int.parse(barcodePosition)].toString() == searchData) {
          searchSts = true;
          barcodeText.text = searchData;
          itemName.text = fields[i][int.parse(itemNamePosition)].toString();
          sellingCost.text =
              fields[i][int.parse(salesPricePosition)].toString();
          mrp.text = fields[i][int.parse(mrpPosition)].toString();
          brand.text = fields[i][int.parse(brandPosition)].toString();
        }
      }
      if (searchSts == false) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) {
              return AlertDialog(
                title: Text('No Data Found'),
                content: Text('Barcode ' +
                    searchData +
                    ' Not Found in Your Product List'),
                actions: [
                  // The "Yes" button
                  TextButton(
                      onPressed: () {
                        search.clear();
                        barcodeText.clear();
                        itemName.clear();
                        sellingCost.clear();
                        mrp.clear();
                        brand.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok')),
                ],
              );
            });
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return _isConnected == true
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: <Widget>[_NomalPopMenu()],
            ),
            body: //dashboardDetails != null
                SingleChildScrollView(
                    child:

                        ///dashboardDetails.data.trialEnds == false
                        Container(
              width: double.infinity,
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color.fromRGBO(115, 197, 237, 1),
                    Color.fromRGBO(58, 177, 158, 1)
                  ])),
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 5),
                      // Text(
                      //   'dashboardDetails.data.note',
                      //   style: TextStyle(
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 5, right: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                width: MediaQuery.of(context).size.width * 1,
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: DropdownButton(
                                  dropdownColor: Colors.white,
                                  items: _getDeviceItems(),
                                  onChanged: (value) =>
                                      setState(() => _device = value),
                                  value: _device,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.brown),
                              onPressed: () {
                                initPlatformState();
                              },
                              child: Text(
                                'Refresh',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      _connected ? Colors.red : Colors.green),
                              onPressed: _connected ? _disconnect : _connect,
                              child: Text(
                                _connected ? 'Disconnect' : 'Connect',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 1,
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Row(children: [
                            Expanded(
                              child: TextFormField(
                                  controller: search,
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.search),
                                    hintText: "Search Barcode",
                                  )),
                            ),
                            Container(
                              height: 20,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              width: 1,
                              color: Colors.grey[200],
                            ),
                            InkWell(
                              child: Row(
                                children: [
                                  Text(
                                    "Search",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                Common.showProgressDialog(context, "Loading..");
                                final tempDir = await DownloadsPathProvider
                                    .downloadsDirectory;
                                String fileName = 'data.csv';
                                String tempPath = tempDir.path;
                                var filePath = tempPath + '/hisan/' + fileName;
                                String path = filePath;
                                bool directoryExists =
                                    await Directory(path).exists();
                                bool fileExists = await File(path).exists();
                                if (directoryExists || fileExists) {
                                  getData(search.text);
                                } else {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text('File Not Found'),
                                          content: Text(
                                              'Please Contact This Number 9961122790 '),
                                          actions: [
                                            // The "Yes" button
                                            TextButton(
                                                onPressed: () {
                                                  search.clear();
                                                  barcodeText.clear();
                                                  itemName.clear();
                                                  sellingCost.clear();
                                                  mrp.clear();
                                                  brand.clear();
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) => Upload(
                                                  //           widget
                                                  //               .token,
                                                  //           _connected,
                                                  //           widget
                                                  //               .type,
                                                  //           widget
                                                  //               .serialNumber)),
                                                  // );
                                                },
                                                child: Text('Ok')),
                                          ],
                                        );
                                      });
                                }
                              },
                            ),
                            Container(
                              height: 20,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              width: 1,
                              color: Colors.grey[200],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              child: Row(
                                children: [Icon(Icons.qr_code)],
                              ),
                              onTap: () {
                                scanBarcodeNormal();
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ])),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 21),
                        child: Text(
                          "Barcode",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
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
                              controller: barcodeText,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 21),
                        child: Text(
                          "Item Name",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 5),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 1,
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextField(
                              controller: itemName,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 21),
                                child: Text(
                                  "Rs.₹",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 5),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: sellingCost,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 28),
                                child: Text(
                                  "MRP.₹",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30, right: 20, bottom: 5),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      controller: mrp,
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
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 21),
                                child: Text(
                                  "Qty",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 5),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (text) {
                                        setState(() {
                                          totalPrice = double.parse(qty.text) *
                                              double.parse(sellingCost.text);
                                          if (qty.text.isNotEmpty) {
                                            totalCost.text =
                                                totalPrice.toString();
                                          }
                                        });
                                      },
                                      controller: qty,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 21),
                                child: Text(
                                  "Brand",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, bottom: 5),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: TextField(
                                      keyboardType: TextInputType.text,
                                      controller: brand,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 21),
                        child: Text(
                          "Total Price ₹",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
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
                              controller: totalCost,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),

                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 21),
                        child: Text(
                          "Employee Id",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 5),
                        child: Container(
                          padding: EdgeInsets.only(left: 10),
                          height: MediaQuery.of(context).size.height * 0.065,
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: TextField(
                              controller: employeeId,
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: RaisedButton(
                          onPressed: () async {
                            String type = widget.type;
                            if (barcodeText.text.isEmpty) {
                              Common.toastMessaage(
                                  'Barcode cannot be empty', Colors.red);
                            } else if (itemName.text.isEmpty) {
                              Common.toastMessaage(
                                  'Item Name cannot be empty', Colors.red);
                            } else if (sellingCost.text.isEmpty) {
                              Common.toastMessaage(
                                  'Selling Price cannot be empty', Colors.red);
                            } else if (mrp.text.isEmpty) {
                              Common.toastMessaage(
                                  'MRP cannot be empty', Colors.red);
                            } else if (qty.text.isEmpty) {
                              Common.toastMessaage(
                                  'Quantity Name cannot be empty', Colors.red);
                            } else if (totalCost.text.isEmpty) {
                              Common.toastMessaage(
                                  'Total Cost cannot be empty', Colors.red);
                            } else if (employeeId.text.isEmpty) {
                              Common.toastMessaage(
                                  'Employee Id cannot be empty', Colors.red);
                            } else if (_connected == false) {
                              Common.toastMessaage(
                                  'Check Your Connection', Colors.red);
                            } else {
                              double totQty = double.parse(qty.text) * 1000;
                              String vString = totQty.toInt().toString();
                              String digiCode = vString.padLeft(int. parse(barcodeDigit), '0');
                              String barcode = barcodeText.text;
                              String Totbarcode =
                                  barcodeText.text + digiCode.toString();

                              final DateFormat formatter =
                                  DateFormat('dd-MM-yyyy');
                              final String formatted =
                                  formatter.format(DateTime.now());
                              showDialog(
                                  context: context,
                                  builder: (BuildContext ctx) {
                                    return AlertDialog(
                                      title: Text(''),
                                      content: Container(
                                          height: 200,
                                          child: Column(
                                            children: [
                                              Text(
                                                companyName,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Expanded(
                                                child: SfBarcodeGenerator(
                                                  value: Totbarcode,
                                                  symbology: Code128(),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 35, top: 10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          itemName.text,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Price:' +
                                                                  sellingCost
                                                                      .text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'MRP:' + mrp.text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              'Qty: ' +
                                                                  qty.text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'brand: ' +
                                                                  brand.text,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          'Net Amount: ' +
                                                              totalCost.text,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          'Date: ' +
                                                              formatted +
                                                              ' ' +
                                                              new DateFormat
                                                                      .jm()
                                                                  .format(DateTime
                                                                      .now()),
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Section: ' +section,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Type: ' +qtyType,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 11,
                                                          ),
                                                        ),

                                                      ],
                                                    ),
                                                  ),
                                                  RotatedBox(
                                                    quarterTurns: 3,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 25,
                                                          child:
                                                              SfBarcodeGenerator(
                                                                  value:
                                                                      employeeId
                                                                          .text,
                                                                  symbology:
                                                                      Code128()),
                                                        ),
                                                        Text(
                                                          'Emp Id:' +
                                                              employeeId.text,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 11,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          )),
                                      actions: [
                                        // The "Yes" button
                                        TextButton(
                                            onPressed: () async {
                                              if (_connected == true) {
                                                testPrint.sample(
                                                    companyName,
                                                    type,
                                                    itemName.text,
                                                    sellingCost.text,
                                                    mrp.text,
                                                    qty.text,
                                                    totalCost.text,
                                                    employeeId.text,
                                                    Totbarcode,
                                                    brand.text,
                                                    qtyType,section,barcodeText.text);
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Connection(
                                                              widget.token,
                                                              widget.type,
                                                              widget
                                                                  .serialNumber)),
                                                );
                                              }
                                            },
                                            child: Text('Print')),
                                        TextButton(
                                            onPressed: () {
                                              barcodeText.clear();
                                              itemName.clear();
                                              sellingCost.clear();
                                              mrp.clear();
                                              qty.clear();
                                              totalCost.clear();
                                              employeeId.clear();
                                              search.clear();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('New'))
                                      ],
                                    );
                                  });
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
                              "Print",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: Column(
                          children: [
                            Text(
                              'Powered by',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 130,
                              child: Image.asset(
                                "assets/images/hisanLogo.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            // Text('Hisan',textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 40,fontWeight: FontWeight.bold
                            //   ),),
                            Text(
                              'www.hisantechnology.com',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                    // : AlertDialog(
                    //     title: Text('Your Trail Version Ended'),
                    //     content:
                    //         Text('Please Contact This Number 9961122790'),
                    //     actions: [
                    //       The "Yes" button
                    //       TextButton(
                    //           onPressed: () {
                    //             Common.saveSharedPref("Logout", "success");
                    //             Navigator.of(context).pushAndRemoveUntil(
                    //                 MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         Login(widget.serialNumber)),
                    //                 (Route<dynamic> route) => false);
                    //           },
                    //           child: Text('Yes')),
                    //     ],
                    //   ),
                    )
            // : Container(
            //     child: SplashScreen(
            //       seconds: 6,
            //       loadingText: Text("Loading.. Please Wait"),
            //       photoSize: 100.0,
            //       loaderColor: Colors.blue,
            //     ),
            //   ),
            )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: <Widget>[_NomalPopMenu()],
            ),
            body: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color.fromRGBO(115, 197, 237, 1),
                      Color.fromRGBO(58, 177, 158, 1)
                    ])),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 5, right: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Device:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width: MediaQuery.of(context).size.width * 1,
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                      ),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    items: _getDeviceItems(),
                                    onChanged: (value) =>
                                        setState(() => _device = value),
                                    value: _device,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.brown),
                                onPressed: () {
                                  initPlatformState();
                                },
                                child: Text(
                                  'Refresh',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary:
                                        _connected ? Colors.red : Colors.green),
                                onPressed: _connected ? _disconnect : _connect,
                                child: Text(
                                  _connected ? 'Disconnect' : 'Connect',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 1,
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                ),
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(children: [
                              Expanded(
                                child: TextFormField(
                                    controller: search,
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      prefixIcon: Icon(Icons.search),
                                      hintText: "Search Barcode",
                                    )),
                              ),
                              Container(
                                height: 20,
                                margin: EdgeInsets.only(left: 5, right: 5),
                                width: 1,
                                color: Colors.grey[200],
                              ),
                              InkWell(
                                child: Row(
                                  children: [
                                    Text(
                                      "Search",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                  getData(search.text);
                                },
                              ),
                              Container(
                                height: 20,
                                margin: EdgeInsets.only(left: 5, right: 5),
                                width: 1,
                                color: Colors.grey[200],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                child: Row(
                                  children: [Icon(Icons.qr_code)],
                                ),
                                onTap: () {
                                  scanBarcodeNormal();
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ])),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 21),
                          child: Text(
                            "Barcode",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
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
                                controller: barcodeText,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 21),
                          child: Text(
                            "Item Name",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 5),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.06,
                            width: MediaQuery.of(context).size.width * 1,
                            padding: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: TextField(
                                controller: itemName,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 21),
                                  child: Text(
                                    "Rs.₹",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 5),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: sellingCost,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                    "MRP.₹",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 20, bottom: 5),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: mrp,
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
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 21),
                                  child: Text(
                                    "Qty",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, bottom: 5),
                                  child: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        onChanged: (text) {
                                          setState(() {
                                            totalPrice = double.parse(
                                                    qty.text) *
                                                double.parse(sellingCost.text);
                                            if (qty.text.isNotEmpty) {
                                              totalCost.text =
                                                  totalPrice.toString();
                                            }
                                          });
                                        },
                                        controller: qty,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 21),
                          child: Text(
                            "Total Price ₹",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
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
                                controller: totalCost,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 21),
                          child: Text(
                            "Employee Id",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 5),
                          child: Container(
                            padding: EdgeInsets.only(left: 10),
                            height: MediaQuery.of(context).size.height * 0.065,
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: TextField(
                                controller: employeeId,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          child: RaisedButton(
                            onPressed: () async {
                              String type = widget.type;
                              if (barcodeText.text.isEmpty) {
                                Common.toastMessaage(
                                    'Barcode cannot be empty', Colors.red);
                              } else if (itemName.text.isEmpty) {
                                Common.toastMessaage(
                                    'Item Name cannot be empty', Colors.red);
                              } else if (sellingCost.text.isEmpty) {
                                Common.toastMessaage(
                                    'Selling Price cannot be empty',
                                    Colors.red);
                              } else if (mrp.text.isEmpty) {
                                Common.toastMessaage(
                                    'MRP cannot be empty', Colors.red);
                              } else if (qty.text.isEmpty) {
                                Common.toastMessaage(
                                    'Quantity Name cannot be empty',
                                    Colors.red);
                              } else if (totalCost.text.isEmpty) {
                                Common.toastMessaage(
                                    'Total Cost cannot be empty', Colors.red);
                              } else if (employeeId.text.isEmpty) {
                                Common.toastMessaage(
                                    'Employee Id cannot be empty', Colors.red);
                              } else if (_connected == false) {
                                Common.toastMessaage(
                                    'Check Your Connection', Colors.red);
                              } else {
                                double totQty = double.parse(qty.text) * 1000;
                                String vString = totQty.toInt().toString();
                                String digiCode = vString.padLeft(5, '0');
                                String barcode = barcodeText.text;
                                String Totbarcode =
                                    barcodeText.text + digiCode.toString();

                                final DateFormat formatter =
                                    DateFormat('dd-MM-yyyy');
                                final String formatted =
                                    formatter.format(DateTime.now());
                                showDialog(
                                    context: context,
                                    builder: (BuildContext ctx) {
                                      return AlertDialog(
                                        title: Text(''),
                                        content: Container(
                                            height: 200,
                                            child: Column(
                                              children: [
                                                Text(
                                                  companyName,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Expanded(
                                                  child: SfBarcodeGenerator(
                                                    value: Totbarcode,
                                                    symbology: Code128(),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 35,
                                                              top: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            itemName.text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Price:' +
                                                                    sellingCost
                                                                        .text,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                'MRP:' +
                                                                    mrp.text,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            'Qty: ' + qty.text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            'Net Amount: ' +
                                                                totalCost.text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            'Date: ' +
                                                                formatted +
                                                                ' ' +
                                                                new DateFormat
                                                                        .jm()
                                                                    .format(DateTime
                                                                        .now()),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    RotatedBox(
                                                      quarterTurns: 3,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 25,
                                                            child: SfBarcodeGenerator(
                                                                value:
                                                                    employeeId
                                                                        .text,
                                                                symbology:
                                                                    Code128()),
                                                          ),
                                                          Text(
                                                            'Emp Id:' +
                                                                employeeId.text,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 11,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            )),
                                        actions: [
                                          // The "Yes" button
                                          TextButton(
                                              onPressed: () async {
                                                if (_connected == true) {
                                                  testPrint.sample(
                                                      companyName,
                                                      type,
                                                      itemName.text,
                                                      sellingCost.text,
                                                      mrp.text,
                                                      qty.text,
                                                      totalCost.text,
                                                      employeeId.text,
                                                      Totbarcode,
                                                      brand.text,
                                                      qtyType,section,barcodeText.text);
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Connection(
                                                                widget.token,
                                                                widget.type,
                                                                widget
                                                                    .serialNumber)),
                                                  );
                                                }
                                              },
                                              child: Text('Print')),
                                          TextButton(
                                              onPressed: () {
                                                barcodeText.clear();
                                                itemName.clear();
                                                sellingCost.clear();
                                                mrp.clear();
                                                qty.clear();
                                                totalCost.clear();
                                                employeeId.clear();
                                                search.clear();
                                                Navigator.of(context).pop();
                                                // Navigator.of(
                                                //         context)
                                                //     .pushAndRemoveUntil(
                                                //         MaterialPageRoute(
                                                //             builder: (context) =>
                                                //                 Dashboard(widget.token,_connected,widget.type,widget.serialNumber)),
                                                //         (Route<dynamic> route) =>
                                                //             false);
                                              },
                                              child: Text('New'))
                                        ],
                                      );
                                    });
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
                                "Print",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                'Powered by',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 130,
                                child: Image.asset(
                                  "assets/images/hisanLogo.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              // Text('Hisan',textAlign: TextAlign.center,
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 40,fontWeight: FontWeight.bold
                              //   ),),
                              Text(
                                'www.hisantechnology.com',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //
            // floatingActionButton: FloatingActionButton(
            //   child: Icon(Icons.bluetooth_connected),
            //   onPressed: () =>pickFile(),
            //   backgroundColor: Colors.red,
            // ),
          );
  }

  Widget _NomalPopMenu() {
    return new PopupMenuButton<int>(
        itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              new PopupMenuItem<int>(value: 3, child: new Text('Upload')),
            ],
        onSelected: (int value) {
          setState(() async {
            _value = value;

            if (_value == 1) {
              Common.showProgressDialog(context, "Loading..");
              Common.saveSharedPref("type", 'Barcode');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(widget.token, _connected,
                          'Barcode', widget.serialNumber)),
                  (Route<dynamic> route) => false);
            } else if (_value == 2) {
              Common.showProgressDialog(context, "Loading..");
              Common.saveSharedPref("type", 'Qrcode');
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(widget.token, _connected,
                          'Qrcode', widget.serialNumber)),
                  (Route<dynamic> route) => false);
            } else if (_value == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Upload(lastUpdate)),
              );
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('Please Confirm'),
                      content: Text('Are you sure to Logout?'),
                      actions: [
                        // The "Yes" button
                        // TextButton(
                        //     onPressed: () {
                        //       Common.saveSharedPref("Logout", "success");
                        //       Navigator.of(context).pushAndRemoveUntil(
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   Login(widget.serialNumber)),
                        //           (Route<dynamic> route) => false);
                        //     },
                        //     child: Text('Yes')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'))
                      ],
                    );
                  });
            }
          });
        });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}

type() async {
  //String type= await Common.getSharedPref("type");
  return Text('aaa');
}

class Tag {
  String Barcode;
  String ItemName;
  String Brand;
  String Stock;
  String SalePrice;
  String MRP;

  Tag(this.Barcode, this.ItemName, this.Brand, this.Stock, this.SalePrice,
      this.MRP);

  Map toJson() => {
        'bracode': Barcode.toString(),
        'itemName': ItemName.toString(),
        'brand': Brand.toString(),
        'stock': Stock.toString(),
        'salePrice': SalePrice.toString(),
        'mrp': MRP,
      };
}

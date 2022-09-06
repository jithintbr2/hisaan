import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_check/UpdateModel.dart';
import 'package:flutter_app_check/common.dart';
import 'package:flutter_app_check/dashboard.dart';
import 'package:flutter_app_check/forceUpdate.dart';
import 'package:flutter_app_check/login.dart';
import 'package:flutter_app_check/settings.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unique_identifier/unique_identifier.dart';


class Splash2 extends StatefulWidget {
  @override
  _newSplashState createState() => _newSplashState();
}

class _newSplashState extends State<Splash2> {
  final splashDelay = 2;

  UpdateModel updatedata;
  String  identifier;

  @override
  void initState() {
    super.initState();

    getData();
    //_loadWidget();
  }

  getData() async {

    identifier =await UniqueIdentifier.serial;
       _loadWidget();
    // updatedata = await HttpService.forceUpdate();
    // final newVersion=NewVersion(
    //   androidId:"com.azyan",
    // );
    // final status=await newVersion.getVersionStatus();
    //   identifier =await UniqueIdentifier.serial;
    // print(status.localVersion);
    // print(updatedata.data.minVersion);
    // print(identifier);
    // int versionCompare=status.localVersion.compareTo(updatedata.data.minVersion.toString());
    // if(versionCompare<0)
    // {
    //   _checkVersion();
    // }
    // else
    // {
    //   _loadWidget();
    // }

  }
  void _checkVersion()
  async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ForceUpdate()),
    );
    /*final newVersion=NewVersion(
      androidId:"com.azyan",
    );
    final status=await newVersion.getVersionStatus();

    newVersion.showUpdateDialog(context: context,
      versionStatus: status,
      dialogTitle: "UPDATE!!!",
      dismissButtonText: "Skip",
      dialogText: "Please Update The app From "+ "${status.localVersion}"+" to "+"${status.storeVersion}",
      dismissAction: (){
        SystemNavigator.pop();
      },
      updateButtonText: "Update",

    );*/

  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    // return '';
    // return Timer(_duration, navigationPage);
    return Timer(_duration, routeTOHomePage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(

        width: MediaQuery.of(context).size.width * 0.9,
        height: 900,
        decoration: BoxDecoration(

            gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(115,197,237,1),
                  Color.fromRGBO(58,177,158,1)
                ]
            )

        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 200,
          ),
        ));
  }

  routeTOHomePage() async {
    // Navigator.pushReplacementNamed(context, RouteDashBoard);
    String settings = await Common.getSharedPref("companyName");
    String endDate = await Common.getSharedPref("endDate");
    if (settings != null) {

      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(DateTime.now());
      print(endDate.compareTo(formatted));

      if(endDate.compareTo(formatted)<0)
        {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      Login()),
                  (Route<dynamic> route) => false);
          Common.toastMessaage(
              'Your Package End Please Contact Hisan Technologies', Colors.red);
        }
      else
        {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      Dashboard('aa', false, 'bb', identifier)),
                  (Route<dynamic> route) => false);
        }



    }
    else{
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             Settings()),
      //         (Route<dynamic> route) => false);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  Login()),
              (Route<dynamic> route) => false);
    }
    // String tocken = await Common.getSharedPref("tocken");
    // String type = await Common.getSharedPref("type");
    // print(tocken);
    //
    // if (tocken != null)
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               Dashboard(tocken,false,type,identifier)),
    //           (Route<dynamic> route) => false);
    //
    // else
    //   Navigator.of(context).pushAndRemoveUntil(
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               Login(identifier)),
    //           (Route<dynamic> route) => false);
  }
}


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Common {
  static toastMessaage(message, color) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static saveSharedPref(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == 'tocken') {
      prefs.setString(key, val);
    }
    else if(key=='companyName')
    {
      prefs.setString(key, val);
    }
    else if(key=='type')
    {
      prefs.setString(key, val);
    }
    else if(key=='fileName')
    {
      prefs.setString(key, val);
    }
    else if(key=='barcodePosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='itemNamePosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='brandPosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='stockPosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='salesPricePosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='mrpPosition')
    {
      prefs.setString(key, val);
    }
    else if(key=='settings')
    {
      prefs.setString(key, val);
    }
    else if(key=='endDate')
    {
      prefs.setString(key, val);
    }
    else if(key=='section')
    {
      prefs.setString(key, val);
    }
    else if(key=='productType')
    {
      prefs.setString(key, val);
    }
    else if(key=='ipAddress')
    {
      prefs.setString(key, val);
    }
    else if(key=='lastUpdated')
    {
      prefs.setString(key, val);
    }
    else if(key=='barcodeDigit')
    {
      prefs.setString(key, val);
    }
    else {
      await prefs.clear();
    }
  }

  static  getSharedPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static showProgressDialog(BuildContext context, String title) {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                  ),
                  title.isEmpty
                      ? Container()
                      : Flexible(
                      flex: 8,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }
}

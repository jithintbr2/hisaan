
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_check/common.dart';
import 'package:flutter_app_check/dashboard.dart';
import 'package:flutter_app_check/httpService.dart';
import 'package:flutter_app_check/loginModel.dart';
import 'package:flutter_app_check/settings.dart';



class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController code = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;



    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: size.height,
          decoration: new BoxDecoration(

              gradient: new LinearGradient(
                begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(115,197,237,1),
                    Color.fromRGBO(58,177,158,1)
                  ]
              )
          ),


          child: Stack(

            alignment: Alignment.center,
            children: <Widget>[


              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage:AssetImage('assets/images/logo.png'),
                    radius: 70,
                  ),
                  SizedBox(height: size.height * 0.03),
                 Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, bottom: 10, top: 10),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),

                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: TextField(
                          controller: code,
                          style: TextStyle(color: Colors.white,fontSize: 20.0),
                          keyboardType:TextInputType.text,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person,color: Colors.white,),
                            hintText: 'Secret Code',
                            hintStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: RaisedButton(
                      onPressed: () async {
                        if (code.text.isEmpty) {
                          Common.toastMessaage(
                              'Secret Code cannot be empty', Colors.red);
                        } else if (code.text!='1234') {
                          Common.toastMessaage(
                              'Wrong Code Try Again', Colors.red);
                        }
                        else {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Settings()),
                                  (Route<dynamic> route) => false);

                        }



                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        width: size.width * 0.5,
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(80.0),
                            color: Colors.white
                        ),
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          "Proceed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.1),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child:Column(
                      children: [
                        Text('Powered by',textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                            fontSize: 15,
                          ),),
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
                        Text('www.hisantechnology.com',textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20
                          ),)
                      ],
                    ),
                  ),


                ],
              ),
          Align(),
            ],
          ),
        ),
      ),
    );
  }
}
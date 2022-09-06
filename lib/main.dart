import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app_check/startPage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';


Future<void> main() async {
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  runApp(StartPage());
}



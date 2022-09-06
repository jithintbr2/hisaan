import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_app_check/DashboardModel.dart';
import 'package:flutter_app_check/UpdateModel.dart';
import 'package:flutter_app_check/fileUploadModel.dart';
import 'package:flutter_app_check/loginModel.dart';
import 'package:flutter_app_check/productDetailsModel.dart';
import 'package:flutter_app_check/uploadListModel.dart';



class HttpService {
  static Dio _dio = Dio();
  static final baseUrl =
      "https://login2.co.in/hisan/index.php/Api/";



  static Future login(uanemVar, pass,serialNo) async {
    var params = {
      "mobNumber": uanemVar,
      "password": pass,
      "serialNumber": serialNo,

    };
    try {
      var result = await _dio.get(baseUrl + "login", queryParameters: params);
      LoginModel model = LoginModel.fromJson(result.data);
      print(params);
      print(result);
      return model;
    } catch (Exception) {
      return null;
    }
  }
  static Future productDetails(searchKey,token) async {
    var params = {
      "barCode": searchKey,
      "token": token,

    };
    try {
      var result = await _dio.get(baseUrl + "get_product", queryParameters: params);
      ProductDetailsModel model = ProductDetailsModel.fromJson(result.data);
      print(params);
      print(result);
      return model;
    } catch (Exception) {
      return null;
    }
  }
  static Future uploadList(token) async {
    var params = {
      "token": token,

    };

    try {
      var result = await _dio.get(baseUrl + "get_file_details",queryParameters: params );
      UploadListModel model = UploadListModel.fromJson(result.data);

      print(result);
      return model;
    } catch (Exception) {
      return null;
    }
  }

  static Future fileUpload(token) async {
    var params = {
      "token": token,

    };

    try {
      var result = await _dio.get(baseUrl + "upload_file", queryParameters: params);
      FileUploadModel model = FileUploadModel.fromJson(result.data);

      print(result);
      return model;
    } catch (Exception) {
      return null;
    }
  }
  static Future forceUpdate() async {

    try {
      var result = await _dio.get(baseUrl + "app_update");
      print(result);

      UpdateModel model = UpdateModel.fromJson(result.data);

      return model;
    } catch (Exception) {
      return null;
    }
  }
  static Future dashboard(token) async {
    var params = {
      "token": token,

    };

    try {
      var result = await _dio.get(baseUrl + "dashboard", queryParameters: params);
      DashboardModel model = DashboardModel.fromJson(result.data);

      print(result);
      return model;
    } catch (Exception) {
      return null;
    }
  }


}

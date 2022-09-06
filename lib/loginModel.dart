class LoginModel {
  bool status;
  String message;
  Data data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  String token;
  String fullName;
  String mobNumber;
  String companyName;
  Position position;
  String fileName;

  Data(
      {this.token,
        this.fullName,
        this.mobNumber,
        this.companyName,
        this.position,
        this.fileName});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    fullName = json['fullName'];
    mobNumber = json['mobNumber'];
    companyName = json['companyName'];
    position = json['position'] != null
        ? new Position.fromJson(json['position'])
        : null;
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['fullName'] = this.fullName;
    data['mobNumber'] = this.mobNumber;
    data['companyName'] = this.companyName;
    if (this.position != null) {
      data['position'] = this.position.toJson();
    }
    data['file_name'] = this.fileName;
    return data;
  }
}

class Position {
  int barCode;
  int itemName;
  int brand;
  int stock;
  int salesPrice;
  int mrp;

  Position(
      {this.barCode,
        this.itemName,
        this.brand,
        this.stock,
        this.salesPrice,
        this.mrp});

  Position.fromJson(Map<String, dynamic> json) {
    barCode = json['barCode'];
    itemName = json['itemName'];
    brand = json['brand'];
    stock = json['stock'];
    salesPrice = json['salesPrice'];
    mrp = json['mrp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['barCode'] = this.barCode;
    data['itemName'] = this.itemName;
    data['brand'] = this.brand;
    data['stock'] = this.stock;
    data['salesPrice'] = this.salesPrice;
    data['mrp'] = this.mrp;
    return data;
  }
}
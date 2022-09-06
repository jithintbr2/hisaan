class ProductDetailsModel {
  bool status;
  String message;
  Data data;

  ProductDetailsModel({this.status, this.message, this.data});

  ProductDetailsModel.fromJson(Map<String, dynamic> json) {
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
  int productId;
  int barCode;
  String itemName;
  String brand;
  int stock;
  int salesPrice;
  int mrp;

  Data(
      {this.productId,
        this.barCode,
        this.itemName,
        this.brand,
        this.stock,
        this.salesPrice,
        this.mrp});

  Data.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    barCode = json['barCode'];
    itemName = json['itemName'];
    brand = json['brand'];
    stock = json['stock'];
    salesPrice = json['salesPrice'];
    mrp = json['mrp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['barCode'] = this.barCode;
    data['itemName'] = this.itemName;
    data['brand'] = this.brand;
    data['stock'] = this.stock;
    data['salesPrice'] = this.salesPrice;
    data['mrp'] = this.mrp;
    return data;
  }
}
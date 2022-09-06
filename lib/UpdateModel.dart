class UpdateModel {
  bool status;
  String message;
  Data data;

  UpdateModel({this.status, this.message, this.data});

  UpdateModel.fromJson(Map<String, dynamic> json) {
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
  int id;
  String currentVersion;
  String minVersion;

  Data({this.id, this.currentVersion, this.minVersion});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currentVersion = json['currentVersion'];
    minVersion = json['minVersion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currentVersion'] = this.currentVersion;
    data['minVersion'] = this.minVersion;
    return data;
  }
}
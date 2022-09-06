class UploadListModel {
  bool status;
  String message;
  Data data;

  UploadListModel({this.status, this.message, this.data});

  UploadListModel.fromJson(Map<String, dynamic> json) {
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
  String lastModifiedTime;
  String lastUpdatedTime;
  String isUpdateAvailable;
  String isPositionSet;

  Data(
      {this.lastModifiedTime,
        this.lastUpdatedTime,
        this.isUpdateAvailable,
        this.isPositionSet});

  Data.fromJson(Map<String, dynamic> json) {
    lastModifiedTime = json['lastModifiedTime'];
    lastUpdatedTime = json['lastUpdatedTime'];
    isUpdateAvailable = json['isUpdateAvailable'];
    isPositionSet = json['isPositionSet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lastModifiedTime'] = this.lastModifiedTime;
    data['lastUpdatedTime'] = this.lastUpdatedTime;
    data['isUpdateAvailable'] = this.isUpdateAvailable;
    data['isPositionSet'] = this.isPositionSet;
    return data;
  }
}
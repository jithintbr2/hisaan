class DashboardModel {
  bool status;
  String message;
  Data data;

  DashboardModel({this.status, this.message, this.data});

  DashboardModel.fromJson(Map<String, dynamic> json) {
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
  String note;
  bool trialEnds;

  Data({this.note, this.trialEnds});

  Data.fromJson(Map<String, dynamic> json) {
    note = json['note'];
    trialEnds = json['trial_ends'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['note'] = this.note;
    data['trial_ends'] = this.trialEnds;
    return data;
  }
}
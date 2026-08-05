class ReportModel {
  int? reportableId;
  String? reportableType;
  String? reason;

  ReportModel({this.reportableId, this.reportableType, this.reason});

  ReportModel.fromJson(Map<String, dynamic> json) {
    reportableId = json['reportable_id'];
    reportableType = json['reportable_type'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reportable_id'] = reportableId;
    data['reportable_type'] = reportableType;
    data['reason'] = reason;
    return data;
  }
}

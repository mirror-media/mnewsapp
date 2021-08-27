import 'dart:io';

class AdUnitId{
  String at1AdUnitId;
  String at2AdUnitId;
  String? at3AdUnitId;
  String? hdAdUnitId;
  String? e1AdUnitId;
  String? ftAdUnitId;

  AdUnitId({
    required this.at1AdUnitId,
    required this.at2AdUnitId,
    required this.at3AdUnitId,
    this.e1AdUnitId,
    this.ftAdUnitId,
    this.hdAdUnitId
});

  factory AdUnitId.fromJson(Map<String, dynamic> json, String name) {
    String _platform = 'ios';
    if (Platform.isAndroid) {
      _platform = 'android';
    }

    if(json[_platform][name] == null){
      name = 'others';
    }

    return new AdUnitId(
        at1AdUnitId: json[_platform][name]['at1AdUnitId'],
        at2AdUnitId: json[_platform][name]['at2AdUnitId'],
        at3AdUnitId: json[_platform][name]['at3AdUnitId'],
        hdAdUnitId: json[_platform][name]['hdAdUnitId'],
        e1AdUnitId: json[_platform][name]['e1AdUnitId'],
        ftAdUnitId: json[_platform][name]['ftAdUnitId'],
    );
  }

  Map<String, dynamic> toJson(String name) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    String _platform = 'ios';
    if (Platform.isAndroid) {
      _platform = 'android';
    }
    data[_platform][name]['at1AdUnitId'] = this.at1AdUnitId;
    data[_platform][name]['at2AdUnitId'] = this.at2AdUnitId;
    data[_platform][name]['at3AdUnitId'] = this.at3AdUnitId;
    data[_platform][name]['hdAdUnitId'] = this.hdAdUnitId;
    data[_platform][name]['e1AdUnitId'] = this.e1AdUnitId;
    data[_platform][name]['ftAdUnitId'] = this.ftAdUnitId;
    return data;
  }
}
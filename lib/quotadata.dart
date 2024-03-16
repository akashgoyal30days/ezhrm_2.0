import 'dart:convert';

Lquota lquotaFromJson(String str) => Lquota.fromJson(json.decode(str));

String lquotaToJson(Lquota data) => json.encode(data.toJson());

class Lquota {
  Lquota({
    this.status,
    this.error,
    this.data,
  });

  bool? status;
  String? error;
  List<Datum>? data;

  factory Lquota.fromJson(Map<String, dynamic> json) => Lquota(
        status: json["status"],
        error: json["error"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "error": error,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.id,
    this.totalQuota,
    this.availQuota,
    this.type,
  });

  String? id;
  String? totalQuota;
  String? availQuota;
  String? type;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        totalQuota: json["total_quota"],
        availQuota: json["avail_quota"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "total_quota": totalQuota,
        "avail_quota": availQuota,
        "type": type,
      };
}

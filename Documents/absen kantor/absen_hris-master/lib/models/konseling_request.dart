import 'dart:convert';

class Counseling {
  int id;
  int karyawanId;
  String email;
  String name;
  int usia;
  int workTime;
  DateTime dateRequest;
  String timeRequest;
  String typeCounseling;
  List<Summary> summary;
  String? keluhan;
  String? lokasi;
  String? linkMeet;
  String? rescheduleDate;
  String? rescheduleTime;
  String? reason;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Counseling({
    required this.id,
    required this.karyawanId,
    required this.email,
    required this.name,
    required this.usia,
    required this.workTime,
    required this.dateRequest,
    required this.timeRequest,
    required this.typeCounseling,
    required this.summary,
    this.keluhan,
    this.lokasi,
    this.linkMeet,
    this.rescheduleDate,
    this.rescheduleTime,
    this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Counseling.fromJson(Map<String, dynamic> json) {
    return Counseling(
      id: json['id'],
      karyawanId: json['karyawan_id'],
      email: json['email'],
      name: json['name'],
      usia: json['usia'],
      workTime: json['work_time'],
      dateRequest: DateTime.parse(json['date_request']),
      timeRequest: json['time_request'],
      typeCounseling: json['type_counseling'],
      summary: List<Summary>.from(
          jsonDecode(json['summary']).map((x) => Summary.fromJson(x))),
      keluhan: json['keluhan'],
      lokasi: json['lokasi'],
      linkMeet: json['link_meet'],
      rescheduleDate: json['reschedule_date'],
      rescheduleTime: json['reschedule_time'],
      reason: json['reason'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'karyawan_id': karyawanId,
      'email': email,
      'name': name,
      'usia': usia,
      'work_time': workTime,
      'date_request': dateRequest.toIso8601String(),
      'time_request': timeRequest,
      'type_counseling': typeCounseling,
      'summary': jsonEncode(summary.map((x) => x.toJson()).toList()),
      'keluhan': keluhan,
      'lokasi': lokasi,
      'link_meet': linkMeet,
      'reschedule_date': rescheduleDate,
      'reschedule_time': rescheduleTime,
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<int, int?> getParsedAnswers() {
    Map<int, int?> answersMap = {};
    for (var answer in summary) {
      answersMap[answer.soalId] = answer.jawaban;
    }
    return answersMap;
  }
}

class Summary {
  int soalId;
  int jawaban;

  Summary({
    required this.soalId,
    required this.jawaban,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      soalId: json['soal_id'],
      jawaban: json['jawaban'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soal_id': soalId,
      'jawaban': jawaban,
    };
  }
}

class CounselingResponse {
  final List<Counseling> data;
  final String message;

  CounselingResponse({
    required this.data,
    required this.message,
  });

  factory CounselingResponse.fromJson(Map<String, dynamic> json) {
    var dataFromJson = json['data'] as List;
    List<Counseling> dataList =
        dataFromJson.map((i) => Counseling.fromJson(i)).toList();

    return CounselingResponse(
      data: dataList,
      message: json['message'],
    );
  }
}

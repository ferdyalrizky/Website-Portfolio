class Feedback {
  final int soalFeedbackId;
  final int jawaban;

  Feedback({required this.soalFeedbackId, required this.jawaban});

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      soalFeedbackId: json['soal_feedback_id'],
      jawaban: json['jawaban'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soal_feedback_id': soalFeedbackId,
      'jawaban': jawaban,
    };
  }
}

class Data {
  final int id;
  final int karyawanId;
  final int summaryId;
  final String namaPsikolog;
  final List<Feedback> feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  Data({
    required this.id,
    required this.karyawanId,
    required this.summaryId,
    required this.namaPsikolog,
    required this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    var feedbackList = json['feedback'] as List;
    List<Feedback> feedbackItems =
        feedbackList.map((i) => Feedback.fromJson(i)).toList();

    return Data(
      id: json['id'],
      karyawanId: json['karyawan_id'],
      summaryId: json['summary_id'],
      namaPsikolog: json['nama_psikolog'],
      feedback: feedbackItems,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'karyawan_id': karyawanId,
      'summary_id': summaryId,
      'nama_psikolog': namaPsikolog,
      'feedback': feedback.map((f) => f.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ResponseModel {
  final Data data;
  final String message;

  ResponseModel({required this.data, required this.message});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      data: Data.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
    };
  }
}

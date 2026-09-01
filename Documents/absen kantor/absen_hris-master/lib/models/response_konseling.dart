import 'package:hris_v2/models/pertanyaan_konseling.dart';

class PertanyaanResponse {
  final List<Pertanyaan> data;

  PertanyaanResponse({required this.data});

  // Mengonversi dari JSON ke objek PertanyaanResponse
  factory PertanyaanResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Pertanyaan> pertanyaanList =
        list.map((i) => Pertanyaan.fromJson(i)).toList();

    return PertanyaanResponse(data: pertanyaanList);
  }

  // Mengonversi dari objek PertanyaanResponse ke JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((pertanyaan) => pertanyaan.toJson()).toList(),
    };
  }

  factory PertanyaanResponse.defaultResponse() {
    return PertanyaanResponse(data: []);
  }
}

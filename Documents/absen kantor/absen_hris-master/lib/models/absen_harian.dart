class AbsenHarian {
  String absenMasuk;
  String absenPulang;
  List<String> visits;
  String? gambar;
  String keterangan;

  String lokasi;

  AbsenHarian({
    required this.lokasi,
    required this.absenMasuk,
    required this.absenPulang,
    required this.visits,
    this.gambar,
    required this.keterangan,
  });

  // Factory method to create an instance of the class from a JSON map
  factory AbsenHarian.fromJson(Map<String, dynamic> json) {
    try {
      return AbsenHarian(
        keterangan: json['keterangan'] as String,
        gambar: json['gambar'],
        lokasi: json['lokasi'] as String,
        absenMasuk: json['check_in_time'] as String,
        absenPulang: json['check_out_time'] as String,
        visits: List<String>.from(json['visits'] as List<dynamic>),
      );
    } catch (e) {
      throw Exception('Gagal parsing JSON: $e');
    }
  }
}

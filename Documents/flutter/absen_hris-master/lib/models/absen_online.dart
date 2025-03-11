class AbsenOnline {
  String absenMasuk;
  String absenPulang;
  List<String> visits;
  String? gambar;
  String keterangan;
  String keteranganVisit;
  String lokasi;
  String lokasivisit;
  String lokasiOut;
  List<String> alamat;
  String? isFakeGps;

  AbsenOnline({
    required this.lokasi,
    required this.absenMasuk,
    required this.absenPulang,
    required this.visits,
    required this.lokasivisit,
    required this.lokasiOut,
    this.gambar,
    required this.keterangan,
    required this.keteranganVisit,
    required this.alamat,
    this.isFakeGps,
  });

  // Factory method to create an instance of the class from a JSON map
  factory AbsenOnline.fromJson(Map<String, dynamic> json) {
    try {
      return AbsenOnline(
        lokasiOut: json['lokasi_check_out'] as String,
        keterangan: json['keterangan'] as String,
        keteranganVisit: json['keterangan_visit'] as String,
        gambar: json['gambar'] as String?,
        lokasi: json['lokasi'] as String,
        absenMasuk: json['check_in_time'] as String,
        absenPulang: json['check_out_time'] as String,
        lokasivisit: json['lokasi'] as String,
        alamat: List<String>.from(json['alamat'] as List<dynamic>),
        visits: List<String>.from(json['visits'] as List<dynamic>),
        isFakeGps: json['is_fake_gps'] as String?,
      );
    } catch (e) {
      throw Exception('Gagal parsing JSON: $e');
    }
  }
}

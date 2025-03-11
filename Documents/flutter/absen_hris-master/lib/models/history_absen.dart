class DataAbsen {
  int? idAbsen;
  String? tglAbsen;
  String? checkIn;
  String? checkOut;
  int? hadir;
  int? terlambat;
  int? izin;
  int? sakit;
  int? cuti;
  int? dayoff;
  int? tanpaKeterangan;
  int? alpha;
  int? um;
  int? uangMakan;
  int? durasiLembur;
  int? uangLembur;
  int? uangTrip;
  String? keterangan;
  String? buktiSitc;

  DataAbsen.fromJson(Map<String, dynamic> json)
      : idAbsen = json['id'],
        tglAbsen = json['tanggal'],
        checkIn = json['check_in'],
        checkOut = json['check_out'],
        hadir = json['hadir'],
        terlambat = json['terlambat'],
        izin = json['izin'],
        sakit = json['sakit'],
        cuti = json['cuti'],
        dayoff = json['dayoff'],
        tanpaKeterangan = json['tanpa_keterangan'],
        alpha = json['alfa'],
        um = json['um'],
        uangMakan = json['uang_makan'],
        durasiLembur = json['durasi_lembur'],
        uangLembur = json['uang_lembur'],
        uangTrip = json['uang_trip'],
        keterangan = json['keterangan'],
        buktiSitc = json['bukti_sitc'];
}

class HistroyRekapAbsensi {
  String? bulan;
  String? hadir;
  String? terlambat;
  String? izin;
  String? sakit;
  String? cuti;
  String? dayoff;
  String? alfa;
  String? totalJamLembur;

  HistroyRekapAbsensi.fromJson(Map<String, dynamic> json)
      : bulan = json['bulan'],
        hadir = json['hadir'],
        terlambat = json['terlambat'],
        izin = json['izin'],
        sakit = json['sakit'],
        cuti = json['cuti'],
        dayoff = json['dayoff'],
        alfa = json['alfa'],
        totalJamLembur = json['total_jam_lembur'];
}

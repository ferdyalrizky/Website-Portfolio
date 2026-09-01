class Sik {
  String? karyawan;
  String? keperluan;
  String? tanggalIzin;
  String? keterangan;
  String? tanggalPengajuan;
  String? lampiranPath;
  String? namaCutiNormatif;
  String? create;
  String? updatedAt;
  String? tanggalMulai;
  String? tanggalSelesai;
  String? jenisCuti;

  int? idKaryawan;
  int? idSitc;
  int? izin;
  int? sakit;
  int? cuti;
  int? cutiNormatif;
  int? diverifikasi;
  int? disetujui;
  int? status;

  Sik.fromJson(Map<String, dynamic> json)
      : keperluan = json['keperluan'],
        karyawan = json['karyawan']?['nama_karyawan'] ?? '',
        tanggalIzin = json['tanggal_izin'],
        keterangan = json['keterangan'],
        tanggalPengajuan = json['tanggal_pengajuan'],
        tanggalMulai = json['tanggal_mulai'],
        tanggalSelesai = json['tanggal_selesai'],
        updatedAt = json['updated_at'],
        create = json['created_at'],
        lampiranPath = json['lampiran_file'],
        namaCutiNormatif = json['nama_cuti_normatif'] == null
            ? "Cuti Tahunan"
            : json['nama_cuti_normatif']['cuti_normatif'],
        jenisCuti = json['jenis_cuti'],
        idKaryawan = json['id_karyawan'],
        idSitc = json['id'],
        izin = json['izin'],
        sakit = json['sakit'],
        cuti = json['cuti'],
        cutiNormatif = json['cuti_normatif'],
        diverifikasi = json['diverifikasi'],
        disetujui = json['disetujui'],
        status = json['status'];
}

class Izin {
  int? idIzin;
  int? idKaryawan;
  String? nip;
  String? tglPengajuan;
  String? tglIzin;
  String? keperluan;
  String? dtgTelat;
  String? pulangCpt;
  String? jamMasuk;
  String? jamKeluar;
  String? keterangan;
  String? lampiranPath;
  String? lampiranCepat;
  String? lampiranSementara;
  String? create;
  String? updatedAt;
  String? namaKaryawan;
  int? telat;
  int? status;
  int? diverifikasi;
  int? disetujuhi;

  Izin({
    this.idIzin,
    this.idKaryawan,
    this.nip,
    this.tglPengajuan,
    this.tglIzin,
    this.keperluan,
    this.dtgTelat,
    this.pulangCpt,
    this.namaKaryawan,
    this.jamMasuk,
    this.jamKeluar,
    this.keterangan,
    this.lampiranPath,
    this.telat,
    this.status,
    this.diverifikasi,
    this.disetujuhi,
    this.lampiranCepat,
    this.lampiranSementara,
    this.create,
    this.updatedAt,
  });

  Izin.fromJson(Map<String, dynamic> json)
      : idIzin = json['id'],
        idKaryawan = json['id_karyawan'],
        nip = json['kode_nip'],
        tglPengajuan = json['tanggal_pengajuan'],
        tglIzin = json['tanggal_izin'],
        namaKaryawan = json['karyawan']?['nama_karyawan'] ?? '',
        keperluan = json['keperluan'],
        dtgTelat = json['datang_telat'],
        pulangCpt = json['pulang_cepat'],
        jamMasuk = json['jam_masuk'],
        jamKeluar = json['jam_keluar'],
        keterangan = json['keterangan'],
        lampiranPath = json['lampiran_telat'],
        lampiranCepat = json['lampiran_pulang_cepat'],
        lampiranSementara = json['lampiran_izin_sementara'],
        create = json['created_at'],
        updatedAt = json['updated_at'],
        telat = json['telat'],
        status = json['status'],
        diverifikasi = json['diverifikasi'],
        disetujuhi = json['disetujuhi'];
}

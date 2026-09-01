class GantiHari {
  int? idHari;
  int? idKaryawan;
  String? namaKaryawan;
  String? nip;
  String? tglMasuk;
  String? tglGanti;
  String? keterangan;
  String? create;
  String? updatedAt;
  int? diverifikasi;
  int? disetujui;
  int? status;

  GantiHari({
    this.idHari,
    this.idKaryawan,
    this.nip,
    this.namaKaryawan,
    this.tglMasuk,
    this.tglGanti,
    this.keterangan,
    this.create,
    this.diverifikasi,
    this.disetujui,
    this.status,
    this.updatedAt,
  });

  GantiHari.fromJson(Map<String, dynamic> json)
      : namaKaryawan = json['nama_karyawan'],
        nip = json['kode_nip'],
        tglMasuk = json['tanggal_masuk'],
        tglGanti = json['tanggal_ganti_hari'],
        keterangan = json['keterangan'],
        idHari = json['id'],
        idKaryawan = json['id_karyawan'],
        create = json['create_by'],
        updatedAt = json['updated_at'],
        status = json['status'],
        disetujui = json['disetujui'],
        diverifikasi = json['diverifikasi'];
}

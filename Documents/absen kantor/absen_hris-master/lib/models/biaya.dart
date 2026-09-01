class Biaya {
  String? namaKaryawan;
  String? nip;
  String? jnsKlaimBiaya;
  String? jmlUang;
  String? deskripsiUang;
  String? tglKwintansi;
  String? lampiranAcc;
  String? lampiranKwitansi;
  String? namaAcara;
  String? create;
  String? updatedAt;
  String? keterangan;
  int? idBiaya;
  int? idKaryawan;
  int? status;
  int? disetujui;
  int? diverifikasi;

  Biaya({
    this.idBiaya,
    this.idKaryawan,
    this.nip,
    this.namaKaryawan,
    this.jnsKlaimBiaya,
    this.jmlUang,
    this.deskripsiUang,
    this.keterangan,
    this.tglKwintansi,
    this.updatedAt,
    this.lampiranAcc,
    this.lampiranKwitansi,
    this.namaAcara,
    this.create,
    this.status,
    this.diverifikasi,
    this.disetujui,
  });

  Biaya.fromJson(Map<String, dynamic> json)
      : namaKaryawan = json['karyawan']?['nama_karyawan'] ?? '',
        jnsKlaimBiaya = json['jenis_klaim_biaya'],
        jmlUang = json['jumlah_uang'],
        namaAcara = json['nama_acara'],
        updatedAt = json['updated_at'],
        nip = json['kode_nip'],
        deskripsiUang = json['deskripsi'],
        keterangan = json['keterangan'],
        tglKwintansi = json['tanggal_kwitansi'],
        lampiranAcc = json['lampiran_acc'],
        lampiranKwitansi = json['bukti_kwitansi'],
        idBiaya = json['id'],
        idKaryawan = json['id_karyawan'],
        create = json['created_at'],
        status = json['status'],
        disetujui = json['disetujui'],
        diverifikasi = json['diverifikasi'];
}

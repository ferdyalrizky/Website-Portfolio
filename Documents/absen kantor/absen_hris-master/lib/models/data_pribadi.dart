class DataPribadi {
  int? id;
  String? namaLengkap;
  String? namaPanggilan;
  String? gender;
  String? email;
  String? noHp;
  String? tglLahir;
  String? alamatLengkap;
  String? alamatDomisili;

  String? noKtp;
  String? noKk;
  String? bpjsKes;
  String? bpjsTk;
  String? noRek;
  String? namaRek;
  String? npwp;

  DataPribadi({
    this.id,
    this.namaLengkap,
    this.namaPanggilan,
    this.gender,
    this.email,
    this.noHp,
    this.tglLahir,
    this.alamatLengkap,
    this.alamatDomisili,
    this.noKtp,
    this.noKk,
    this.bpjsKes,
    this.bpjsTk,
    this.noRek,
    this.namaRek,
    this.npwp,
  });

  DataPribadi.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        namaLengkap = json['personal_data_karyawan']['nama_karyawan'],
        namaPanggilan = json['personal_data_karyawan']['name'],
        gender = json['personal_data_karyawan']['gender'],
        email = json['personal_data_karyawan']['email'],
        noHp = json['personal_data_karyawan']['no_hp'],
        tglLahir = json['personal_data_karyawan']["tgl_lahir"],
        alamatLengkap = json['personal_data_karyawan']['alamat_lengkap'],
        alamatDomisili = json['personal_data_karyawan']['alamat_domisili'],
        noKtp = json['no_ktp'],
        noKk = json['no_kk'],
        bpjsKes = json['bpjs_kes'],
        bpjsTk = json['bpjs_tk'],
        noRek = json['no_rekening'],
        namaRek = json['nama_rekening'],
        npwp = json['npwp'];
}

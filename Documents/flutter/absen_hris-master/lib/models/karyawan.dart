import 'dart:convert';

class Karyawan {
  int? id;
  String? nama;
  String? namaKaryawan;
  String? gender;
  String? nip;
  String? username;
  String? email;
  String? noHp;
  String? apiToken;
  String? tglLahir;
  String? alamatLengkap;
  String? alamatDomisili;
  String? departemen;
  String? divisi;
  int? level;
  int? divisiId;
  int? bisnisId;
  int? areaKerjaId;
  String? jobTitle;
  int? jatahCuti;
  String? profilePhotoUrl;
  String? tanggalMasuk;
  String? tanggalKeluar;
  String? deviceToken;

  Karyawan({
    this.id,
    this.nama,
    this.namaKaryawan,
    this.gender,
    this.nip,
    this.username,
    this.email,
    this.noHp,
    this.apiToken,
    this.tglLahir,
    this.alamatLengkap,
    this.alamatDomisili,
    this.level,
    this.departemen,
    this.divisi,
    this.divisiId,
    this.bisnisId,
    this.areaKerjaId,
    this.jobTitle,
    this.jatahCuti,
    this.profilePhotoUrl,
    this.tanggalMasuk,
    this.tanggalKeluar,
    this.deviceToken,
  });

  Karyawan.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nama = json['name'],
        namaKaryawan = json['nama_karyawan'],
        gender = json['gender'],
        nip = json['nip'],
        username = json['username'],
        email = json['email'],
        noHp = json['no_hp'],
        apiToken = json['api_token'],
        tglLahir = json['tgl_lahir'],
        alamatLengkap = json['alamat_lengkap'],
        alamatDomisili = json['alamat_domisili'],
        level = json['level'],
        departemen = json['departemen_id'],
        divisi = json['divisi'],
        divisiId = json['divisi_id'],
        bisnisId = json['bisnis_id'],
        areaKerjaId = json['area_kerja_id'],
        jobTitle = json['job_title'],
        jatahCuti = json['jatah_cuti'],
        profilePhotoUrl = json['profile_photo_path'],
        tanggalMasuk = json['tanggal_masuk'],
        tanggalKeluar = json['tanggal_keluar'],
        deviceToken = json['device_token'] ?? "";
}

class Department {
  int? id;
  String? namaDepartment;

  Department({
    this.id,
    this.namaDepartment,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      namaDepartment: json['nama_department'] as String,
    );
  }

  static Map<String, dynamic> toMap(Department department) => {
        'id': department.id,
        'nama_department': department.namaDepartment,
      };

  static String encode(List<Department> departmens) => json.encode(departmens
      .map<Map<String, dynamic>>(
        (department) => Department.toMap(department),
      )
      .toList());

  static List<Department> decode(String departments) =>
      (json.decode(departments) as List<dynamic>)
          .map<Department>((item) => Department.fromJson(item))
          .toList();
}

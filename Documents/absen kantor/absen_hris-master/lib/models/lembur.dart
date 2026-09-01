import 'karyawan.dart';

class Lembur {
  String? karyawan;
  String? namaKaryawan;
  String? tglLembur;
  String? tglLemburSelesai;
  String? jamMulaiLembur;
  String? jamSelesaiLembur;
  String? keperluanLembur;
  String? durasiLembur;
  String? lampiranPath;
  String? updatedAt;

  bool isSelected = false;

  int? idLembur;
  int? idKaryawan;
  int? status;
  int? disetujui;
  int? diverifikasi;
  int? idManager;
  int? idDepartemen;
  int? createdBy;

  Department? department;

  Lembur.fromJson(Map<String, dynamic> json)
      : namaKaryawan = json['nama_karyawan'],
        karyawan = json['karyawan']?['nama_karyawan'] ?? '',
        createdBy = json['created_by'],
        tglLembur = json['tanggal'],
        tglLemburSelesai = json['tanggal_selesai'],
        updatedAt = json['updated_at'],
        jamMulaiLembur = json['mulai_lembur'],
        jamSelesaiLembur = json['selesai_lembur'],
        keperluanLembur = json['keperluan'],
        durasiLembur = json['durasi_lembur'],
        idLembur = json['id'],
        idKaryawan = json['id_karyawan'],
        status = json['status'],
        disetujui = json['disetujui'],
        diverifikasi = json['diverifikasi'],
        idManager = json['created_by'],
        idDepartemen = json['id_department'],
        lampiranPath = json['bukti_lembur'],
        department = Department.fromJson(json['department']);
}

class Pertemuan {
  final int id;
  final int idKaryawan;
  final String nip;
  final String judul;
  final String jenisRutinitas;
  final String typePertemuan;
  final String? tglSelesai;
  final String tglPertemuan;
  final String? tenggatWaktu;
  final List<Babu> peserta;
  final String jamAwal;
  final String jamAkhir;
  final int durasi;
  final int pengingat;
  final String lokasi;
  final String detailLokasi;
  final String deskripsi;
  final String? tingkatan;
  final String linkPertemuan;
  final String? idDepartemen;
  final String? bisnisId;
  final String? areaKerjaId;
  final int kehadiran;
  final String createdBy;
  final bool isCanDelete;
  final bool isCanEdit;
  final bool isAttendance;
  final String creator;

  Pertemuan({
    required this.id,
    required this.idKaryawan,
    required this.nip,
    required this.judul,
    required this.jenisRutinitas,
    required this.typePertemuan,
    this.tglSelesai,
    required this.tglPertemuan,
    this.tenggatWaktu,
    required this.peserta,
    required this.jamAwal,
    required this.jamAkhir,
    required this.durasi,
    required this.pengingat,
    required this.lokasi,
    required this.detailLokasi,
    required this.deskripsi,
    this.tingkatan,
    required this.linkPertemuan,
    this.idDepartemen,
    this.bisnisId,
    this.areaKerjaId,
    required this.kehadiran,
    required this.createdBy,
    required this.isCanDelete,
    required this.isCanEdit,
    required this.isAttendance,
    required this.creator,
  });

  factory Pertemuan.fromJson(Map<String, dynamic> json) {
    var pesertaList = json['peserta'] as List;
    List<Babu> peserta = pesertaList.map((i) => Babu.fromJson(i)).toList();

    return Pertemuan(
      id: json['id'],
      idKaryawan: json['id_karyawan'],
      nip: json['nip'],
      judul: json['judul'],
      jenisRutinitas: json['jenis_rutinitas'],
      typePertemuan: json['type_pertemuan'],
      tglSelesai: json['tgl_selesai'],
      tglPertemuan: json['tgl_pertemuan'],
      tenggatWaktu: json['tenggat_waktu'],
      peserta: peserta,
      jamAwal: json['jam_awal'],
      jamAkhir: json['jam_akhir'],
      durasi: json['durasi'],
      pengingat: json['pengingat'],
      lokasi: json['lokasi'],
      detailLokasi: json['detail_lokasi'],
      deskripsi: json['deskripsi'],
      tingkatan: json['tingkatan'],
      linkPertemuan: json['link_pertemuan'],
      idDepartemen: json['id_departemen'],
      bisnisId: json['bisnis_id'],
      areaKerjaId: json['area_kerja_id'],
      kehadiran: json['kehadiran'],
      createdBy: json['created_by'],
      isCanDelete: json['is_can_delete'],
      isCanEdit: json['is_can_edit'],
      isAttendance: json['is_attendance'],
      creator: json['creator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_karyawan': idKaryawan,
      'nip': nip,
      'judul': judul,
      'jenis_rutinitas': jenisRutinitas,
      'type_pertemuan': typePertemuan,
      'tgl_selesai': tglSelesai,
      'tgl_pertemuan': tglPertemuan,
      'tenggat_waktu': tenggatWaktu,
      'peserta': peserta.map((p) => p.toJson()).toList(),
      'jam_awal': jamAwal,
      'jam_akhir': jamAkhir,
      'durasi': durasi,
      'pengingat': pengingat,
      'lokasi': lokasi,
      'detail_lokasi': detailLokasi,
      'deskripsi': deskripsi,
      'tingkatan': tingkatan,
      'link_pertemuan': linkPertemuan,
      'id_departemen': idDepartemen,
      'bisnis_id': bisnisId,
      'area_kerja_id': areaKerjaId,
      'kehadiran': kehadiran,
      'created_by': createdBy,
      'is_can_delete': isCanDelete,
      'is_can_edit': isCanEdit,
      'is_attendance': isAttendance,
      'creator': creator,
    };
  }
}

class Babu {
  final String nip;
  final String name;
  final bool? attendance;

  Babu({
    required this.nip,
    required this.name,
    this.attendance,
  });

  factory Babu.fromJson(Map<String, dynamic> json) {
    return Babu(
      nip: json['nip'],
      name: json['name'],
      attendance: json['attendance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'name': name,
      'attendance': attendance,
    };
  }
}

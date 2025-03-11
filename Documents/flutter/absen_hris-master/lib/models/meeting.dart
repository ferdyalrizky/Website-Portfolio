class Meeting {
  final int id;
  final int idKaryawan;
  final String nip;
  final String judul;
  final String jenisRutinitas;
  final String typePertemuan;
  final DateTime? tglSelesai;
  final DateTime tglPertemuan;
  final DateTime? tenggatWaktu;
  final List<Peserta> peserta;
  final String jamAwal;
  final String jamAkhir;
  final int durasi;
  final int pengingat;
  final String lokasi;
  final String detailLokasi;
  final String deskripsi;
  final String? tingkatan;
  final String linkPertemuan;
  final String linkPendukung;
  final int? idDepartemen;
  final int? bisnisId;
  final int? areaKerjaId;
  final int kehadiran;
  final String createdBy; // This can remain as is
  final bool isCanDelete;
  final bool isCanEdit;
  final bool isAttendance;

  Meeting({
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
    required this.linkPendukung,
    this.idDepartemen,
    this.bisnisId,
    this.areaKerjaId,
    required this.kehadiran,
    required this.createdBy,
    required this.isCanDelete,
    required this.isCanEdit,
    required this.isAttendance,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    print('Creater ID: ${json['created_by']}'); // Debugging line

    return Meeting(
      id: json['id'] ?? 0,
      idKaryawan: json['id_karyawan'] ?? 0,
      nip: json['nip'] ?? '',
      judul: json['judul'] ?? '',
      jenisRutinitas: json['jenis_rutinitas'] ?? '',
      typePertemuan: json['type_pertemuan'] ?? '',
      tglSelesai: json['tgl_selesai'] != null
          ? DateTime.parse(json['tgl_selesai'])
          : null,
      tglPertemuan: DateTime.parse(json['tgl_pertemuan']),
      tenggatWaktu: json['tenggat_waktu'] != null
          ? DateTime.parse(json['tenggat_waktu'])
          : null,
      peserta:
          (json['peserta'] as List).map((i) => Peserta.fromJson(i)).toList(),
      jamAwal: json['jam_awal'] ?? '',
      jamAkhir: json['jam_akhir'] ?? '',
      durasi: json['durasi'] ?? 0,
      pengingat: json['pengingat'] ?? 0,
      lokasi: json['lokasi'] ?? '',
      detailLokasi: json['detail_lokasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      tingkatan: json['tingkatan'],
      linkPertemuan: json['link_pertemuan'] ?? '',
      linkPendukung: json['link_pendukung'] ?? '',
      idDepartemen: json['id_departemen'],
      bisnisId: json['bisnis_id'],
      areaKerjaId: json['area_kerja_id'],
      kehadiran: json['kehadiran'] ?? 0,
      createdBy: json['created_by'] ?? '', // This can remain as is
      isCanDelete: json['is_can_delete'] is bool
          ? json['is_can_delete']
          : (json['is_can_delete']?.toString().toLowerCase() == 'true') ??
              false,

      isCanEdit: json['is_can_edit'] is bool
          ? json['is_can_edit']
          : (json['is_can_edit']?.toString().toLowerCase() == 'true') ?? false,

      isAttendance: json['is_attendance'] is bool
          ? json['is_attendance']
          : (json['is_attendance']?.toString().toLowerCase() == 'true') ??
              false,
    );
  }
}

class Peserta {
  String nip;
  String name;
  bool? attendance;
  String imgUrl;

  Peserta({
    required this.nip,
    required this.name,
    this.attendance,
    required this.imgUrl,
  });

  factory Peserta.fromJson(Map<String, dynamic> json) {
    return Peserta(
      nip: json['nip'],
      name: json['name'],
      attendance: json['attendance'] is bool
          ? json['attendance']
          : (json['attendance']?.toString().toLowerCase() == 'true')
              ? true
              : (json['attendance']?.toString().toLowerCase() == 'false')
                  ? false
                  : null, // Keeps null if it's neither 'true' nor 'false'
      imgUrl: json['img_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'name': name,
      'attendance': attendance,
      'img_url': imgUrl,
    };
  }
}

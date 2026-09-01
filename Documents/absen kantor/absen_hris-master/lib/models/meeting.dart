class Meeting {
  int id;
  int idKaryawan;
  String nip;
  String judul;
  String jenisRutinitas;
  String typePertemuan;
  DateTime? tglSelesai;
  DateTime tglPertemuan;
  DateTime? tenggatWaktu;
  List<Peserta> peserta;
  String jamAwal;
  String jamAkhir;
  int durasi;
  int pengingat;
  String lokasi;
  String detailLokasi;
  String deskripsi;
  String? tingkatan;
  String linkPertemuan;
  int? idDepartemen;
  int? bisnisId;
  int? areaKerjaId;
  int kehadiran;
  String createdBy;

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
    this.idDepartemen,
    this.bisnisId,
    this.areaKerjaId,
    required this.kehadiran,
    required this.createdBy,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    var pesertaList = json['peserta'] as List;
    List<Peserta> pesertaItems =
        pesertaList.map((i) => Peserta.fromJson(i)).toList();

    return Meeting(
      id: json['id'],
      idKaryawan: json['id_karyawan'],
      nip: json['nip'],
      judul: json['judul'],
      jenisRutinitas: json['jenis_rutinitas'],
      typePertemuan: json['type_pertemuan'],
      tglSelesai: json['tgl_selesai'] != null
          ? DateTime.parse(json['tgl_selesai'])
          : null,
      tglPertemuan: DateTime.parse(json['tgl_pertemuan']),
      tenggatWaktu: json['tenggat_waktu'] != null
          ? DateTime.parse(json['tenggat_waktu'])
          : null,
      peserta: pesertaItems,
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
      'tgl_selesai': tglSelesai?.toIso8601String(),
      'tgl_pertemuan': tglPertemuan.toIso8601String(),
      'tenggat_waktu': tenggatWaktu?.toIso8601String(),
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
    };
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
      attendance: json['attendance'],
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

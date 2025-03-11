class Aktifitas {
  final int id;
  final int? idProject;
  final String nip;
  final String judulTodo;
  final String descTodo;
  final String? pemberiTugas;
  final DateTime tglMulai;
  final DateTime tglSelesai;
  final int status;
  final String? foto;
  final String? linkPendukung;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? jamMulai;
  final String? jamSelesai;
  final int idDept;

  Aktifitas({
    required this.id,
    this.idProject,
    required this.nip,
    required this.judulTodo,
    required this.descTodo,
    this.pemberiTugas,
    required this.tglMulai,
    required this.tglSelesai,
    required this.status,
    this.foto,
    this.linkPendukung,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.jamMulai,
    this.jamSelesai,
    required this.idDept,
  });

  factory Aktifitas.fromJson(Map<String, dynamic> json) {
    return Aktifitas(
      id: json['id'],
      idProject: json['id_project'],
      nip: json['nip'],
      judulTodo: json['judul_todo'],
      descTodo: json['desc_todo'],
      pemberiTugas: json['pemberi_tugas'],
      tglMulai: DateTime.parse(json['tgl_mulai']),
      tglSelesai: DateTime.parse(json['tgl_selesai']),
      status: json['status'],
      foto: json['file_pendukung'],
      linkPendukung: json['link_pendukung'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
      idDept: json['id_dept'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_project': idProject,
      'nip': nip,
      'judul_todo': judulTodo,
      'desc_todo': descTodo,
      'pemberi_tugas': pemberiTugas,
      'tgl_mulai': tglMulai,
      'tgl_selesai': tglSelesai,
      'status': status,
      'foto': foto,
      'link_pendukung': linkPendukung,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'id_dept': idDept,
    };
  }
}

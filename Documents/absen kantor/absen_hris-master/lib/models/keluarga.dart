class Keluarga {
  int? id;
  int? idKaryawan;
  String? statusNikah;
  String? namaPasangan;
  String? namaAnak1;
  String? dobAnak1;
  String? namaAnak2;
  String? dobAnak2;
  String? namaAnak3;
  String? dobAnak3;
  String? namaAyah;
  String? noHpAyah;
  String? namaIbu;
  String? noHpIbu;
  String? namaKontakEmergensi;
  String? hubunganEmergensi;
  String? noHpEmergensi;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;

  Keluarga(
      {this.id,
      this.idKaryawan,
      this.statusNikah,
      this.namaPasangan,
      this.namaAnak1,
      this.dobAnak1,
      this.namaAnak2,
      this.dobAnak2,
      this.namaAnak3,
      this.dobAnak3,
      this.namaAyah,
      this.noHpAyah,
      this.namaIbu,
      this.noHpIbu,
      this.namaKontakEmergensi,
      this.hubunganEmergensi,
      this.noHpEmergensi,
      this.deletedAt,
      this.createdAt,
      this.updatedAt});

  Keluarga.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idKaryawan = json['id_karyawan'];
    statusNikah = json['status_nikah'] ?? "Belum Menikah";
    namaPasangan = json['nama_pasangan'] ?? "";
    namaAnak1 = json['nama_anak_1'] ?? "";
    dobAnak1 = json['tgl_lahir_anak_1'] ?? "";
    namaAnak2 = json['nama_anak_2'] ?? "";
    dobAnak2 = json['tgl_lahir_anak_2'] ?? "";
    namaAnak3 = json['nama_anak_3'] ?? "";
    dobAnak3 = json['tgl_lahir_anak_3'] ?? "";
    namaAyah = json['nama_ayah'] ?? "";
    noHpAyah = json['no_hp_ayah'] ?? "";
    namaIbu = json['nama_ibu'] ?? "";
    noHpIbu = json['no_hp_ibu'] ?? "";
    namaKontakEmergensi = json['nama_kontak_emergensi'] ?? "";
    hubunganEmergensi = json['hubungan_emergensi'] ?? "";
    noHpEmergensi = json['no_hp_emergensi'] ?? "";
    deletedAt = json['deleted_at'] ?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_karyawan'] = idKaryawan;
    data['status_nikah'] = statusNikah;
    data['nama_pasangan'] = namaPasangan;
    data['nama_anak_1'] = namaAnak1;
    data['nama_anak_2'] = namaAnak2;
    data['nama_anak_3'] = namaAnak3;
    data['nama_ayah'] = namaAyah;
    data['no_hp_ayah'] = noHpAyah;
    data['nama_ibu'] = namaIbu;
    data['no_hp_ibu'] = noHpIbu;
    data['nama_kontak_emergensi'] = namaKontakEmergensi;
    data['hubungan_emergensi'] = hubunganEmergensi;
    data['no_hp_emergensi'] = noHpEmergensi;
    data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

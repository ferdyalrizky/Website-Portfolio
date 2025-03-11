class CutiNormatif {
  int? id;
  String? namaCuti;
  int? jumlahCuti;
  int? bisnisId;

  CutiNormatif({
    this.id,
    this.namaCuti,
    this.jumlahCuti,
    this.bisnisId,
  });

  CutiNormatif.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        namaCuti = json['cuti_normatif'],
        jumlahCuti = json['jumlah_cuti'],
        bisnisId = json['bisnis_id'];
}

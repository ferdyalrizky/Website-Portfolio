class AreaKerja {
  final int id;
  final String areaKerja;
  final String lokasi;

  AreaKerja({required this.id, required this.areaKerja, required this.lokasi});

  factory AreaKerja.fromJson(Map<String, dynamic> json) {
    return AreaKerja(
      id: json['id'],
      areaKerja: json['area_kerja'],
      lokasi: json['lokasi'],
    );
  }
}

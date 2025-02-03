class Product {
  final int id;
  final String barcode;
  final String serialNumber;
  final String noPal;
  final String tanggal;
  final String blok;
  final String container;
  final double p;
  final double l;
  final String lokasi;
  final int codeRak;
  final String createdBy;
  final String keterangan;
  final String namaBarang;

  Product({
    required this.id,
    required this.barcode,
    required this.serialNumber,
    required this.noPal,
    required this.tanggal,
    required this.blok,
    required this.container,
    required this.p,
    required this.l,
    required this.lokasi,
    required this.codeRak,
    required this.createdBy,
    required this.keterangan,
    required this.namaBarang,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      barcode: json['barcode'],
      serialNumber: json['serial_number'] ?? 'TIDAK ADA',
      noPal: json['no_pal'],
      tanggal: json['tanggal'],
      blok: json['blok'],
      container: json['container'] ?? 'TIDAK ADA',
      p: double.parse(json['p']),
      l: double.parse(json['l']),
      lokasi: json['lokasi'],
      codeRak: json['code_rak'],
      createdBy: json['created_by'],
      keterangan: json['keterangan'],
      namaBarang: json['get_nama_brg']['nama'],
    );
  }
}

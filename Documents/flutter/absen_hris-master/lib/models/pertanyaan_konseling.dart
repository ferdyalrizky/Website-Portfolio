class Pertanyaan {
  final int id;
  final String pertanyaan;

  Pertanyaan({required this.id, required this.pertanyaan});

  // Mengonversi dari JSON ke objek Pertanyaan
  factory Pertanyaan.fromJson(Map<String, dynamic> json) {
    return Pertanyaan(
      id: json['id'],
      pertanyaan: json['pertanyaan'],
    );
  }

  // Mengonversi dari objek Pertanyaan ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pertanyaan': pertanyaan,
    };
  }
}

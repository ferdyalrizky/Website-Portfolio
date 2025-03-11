// Model untuk setiap sesi
class Jam {
  final String slug;
  final String name;
  final String status;

  Jam({
    required this.slug,
    required this.name,
    required this.status,
  });

  // Factory method untuk membuat objek Session dari JSON
  factory Jam.fromJson(Map<String, dynamic> json) {
    return Jam(
      slug: json['slug'],
      name: json['name'],
      status: json['status'],
    );
  }

  // Method untuk mengubah objek Session menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'status': status,
    };
  }
}

// Model untuk keseluruhan data
class JamResponse {
  final List<Jam> data;
  final String message;

  JamResponse({
    required this.data,
    required this.message,
  });

  // Factory method untuk membuat objek SessionData dari JSON
  factory JamResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<Jam> dataItems = dataList.map((i) => Jam.fromJson(i)).toList();

    return JamResponse(
      data: dataItems,
      message: json['message'],
    );
  }

  // Method untuk mengubah objek SessionData menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((session) => session.toJson()).toList(),
      'message': message,
    };
  }
}

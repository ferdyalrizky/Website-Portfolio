class Visiting {
  String time;
  String address;

  Visiting({
    required this.time,
    required this.address,
  });

  factory Visiting.fromJson(Map<String, dynamic> json) {
    return Visiting(
      time: json['time'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'address': address,
    };
  }
}

class Room {
  final String code;
  final bool isActive;

  Room({required this.code, required this.isActive});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      code: json['code'],
      isActive: json['isActive'],
    );
  }
}

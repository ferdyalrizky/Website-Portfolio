class AbsenData {
  String tanggal;
  String timeIn;
  String timeOut;
  List<String>? visits;

  AbsenData({
    required this.tanggal,
    required this.timeIn,
    required this.timeOut,
    this.visits,
  });

  // Factory method to create an instance of the class from a JSON map
  factory AbsenData.fromJson(Map<String, dynamic> json) {
    return AbsenData(
      tanggal: json['date'],
      timeIn: json['time_in'] ?? "",
      timeOut: json['time_out'] ?? "",
      visits: json['time_visit'] != null
          ? List<String>.from(json['time_visit'])
          : null,
    );
  }
}

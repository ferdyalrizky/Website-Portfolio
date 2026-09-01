class DateStatus {
  final DateTime date; // Change this to DateTime
  final String status;

  DateStatus({required this.date, required this.status});

  // Factory method to create a DateStatus from JSON
  factory DateStatus.fromJson(Map<String, dynamic> json) {
    return DateStatus(
      date: DateTime.parse(json['date']), // Parse the date string to DateTime
      status: json['status'],
    );
  }

  // Method to convert DateStatus to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(), // Convert DateTime to ISO 8601 string
      'status': status,
    };
  }
}

// Model for the entire response
class StatusResponse {
  List<DateStatus> data;
  String message;

  StatusResponse({required this.data, required this.message});

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<DateStatus> statusDataList =
        dataList.map((i) => DateStatus.fromJson(i)).toList();

    return StatusResponse(
      data: statusDataList,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((statusData) => statusData.toJson()).toList(),
      'message': message,
    };
  }
}

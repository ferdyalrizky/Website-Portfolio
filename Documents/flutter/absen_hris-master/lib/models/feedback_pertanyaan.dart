class FeedbackQuestion {
  final List<PertanyaanFeedback> data;

  FeedbackQuestion({required this.data});

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<PertanyaanFeedback> questionsList =
        list.map((i) => PertanyaanFeedback.fromJson(i)).toList();

    return FeedbackQuestion(data: questionsList);
  }
}

class PertanyaanFeedback {
  final int id;
  final String pertanyaanfeedback;

  PertanyaanFeedback({required this.id, required this.pertanyaanfeedback});

  factory PertanyaanFeedback.fromJson(Map<String, dynamic> json) {
    return PertanyaanFeedback(
      id: json['id'],
      pertanyaanfeedback: json['pertanyaan'],
    );
  }
}

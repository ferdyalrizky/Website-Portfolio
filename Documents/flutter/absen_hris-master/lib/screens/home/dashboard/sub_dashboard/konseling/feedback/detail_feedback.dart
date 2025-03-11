import 'package:flutter/material.dart';
import 'package:hris_v2/models/feedback.dart' as hrisFeedback;

class DetailFeedback extends StatefulWidget {
  final List<hrisFeedback.Feedback> feedbackList;
  final Map<int, int?> selectedAnswers;

  const DetailFeedback({
    Key? key,
    required this.feedbackList,
    required this.selectedAnswers,
  }) : super(key: key);

  @override
  State<DetailFeedback> createState() => _DetailFeedbackState();
}

class _DetailFeedbackState extends State<DetailFeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Kuisioner"),
      ),
      body: ListView.builder(
        itemCount: widget.feedbackList.length,
        itemBuilder: (context, index) {
          final feedback = widget.feedbackList[index];
          final answer = widget.selectedAnswers[feedback.soalFeedbackId];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Soal Feedback ID: ${feedback.soalFeedbackId}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Jawaban: ${feedback.jawaban}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: RadioListTile<int>(
                        title: Text('${i}'),
                        value: i,
                        groupValue: answer,
                        onChanged: (value) {
                          // Update selected answer
                          widget.selectedAnswers[feedback.soalFeedbackId] =
                              value;
                        },
                        activeColor: Colors.black,
                      ),
                    );
                  }),
                ),
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}

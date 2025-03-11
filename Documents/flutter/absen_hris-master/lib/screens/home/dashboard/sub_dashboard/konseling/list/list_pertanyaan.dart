import 'package:flutter/material.dart';
import 'package:hris_v2/models/pertanyaan_konseling.dart';

class KuisionerScreen extends StatelessWidget {
  final List<Pertanyaan> pertanyaanList;
  final Map<int, int?> selectedAnswers;

  const KuisionerScreen({
    Key? key,
    required this.pertanyaanList,
    required this.selectedAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Kuisioner"),
      ),
      body: ListView.builder(
        itemCount: pertanyaanList.length,
        itemBuilder: (context, index) {
          final pertanyaan = pertanyaanList[index];
          final answer = selectedAnswers[pertanyaan.id];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Menyelaraskan bagian atas
                  children: [
                    Text(
                      "${index + 1}.", // Nomor pertanyaan
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                        width: 8), // Jarak antara nomor dan teks pertanyaan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Menyelaraskan teks ke kiri
                        children: [
                          Text(
                            pertanyaan.pertanyaan, // Teks pertanyaan
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
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
                        onChanged: (value) {},
                        activeColor: Colors.black,
                      ),
                    );
                  }),
                ),
                if (answer != null) ...[],
                Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/models/feedback_pertanyaan.dart';
import 'package:hris_v2/models/konseling_request.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/konseling.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FormFeedback extends StatefulWidget {
  final Karyawan currUser;
  final List<PertanyaanFeedback> pertanyaanfeedback;
  final Counseling konseling;
  const FormFeedback(
      {super.key,
      required this.currUser,
      required this.pertanyaanfeedback,
      required this.konseling});

  @override
  State<FormFeedback> createState() => _FormFeedbackState();
}

class _FormFeedbackState extends State<FormFeedback> {
  late Future<FeedbackQuestion> futurePertanyaan;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<int, int?> selectedAnswers = {};
  bool hasError = false;

  Future<FeedbackQuestion> fetchPertanyaan() async {
    const int maxRetries = 5;
    int attempt = 0;

    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('pertanyaan_cache');
    if (cachedData != null) {
      print("Using cached data");
      return FeedbackQuestion.fromJson(json.decode(cachedData));
    }

    while (attempt < maxRetries) {
      try {
        final response = await http.get(Uri.parse(
            'http://app.fagetti.com/api/konseling/feedback/pertanyaan'));

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          await prefs.setString('pertanyaan_cache', response.body);
          return FeedbackQuestion.fromJson(json.decode(response.body));
        } else {
          throw Exception('Failed to load questions: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching questions: $e');
        if (cachedData != null) {
          return FeedbackQuestion.fromJson(json.decode(cachedData));
        }
      }
    }

    throw Exception('Max retries exceeded for fetching questions');
  }

  @override
  void initState() {
    super.initState();
    futurePertanyaan = fetchPertanyaan();
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('No questions available.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  _onSubmitKonselingBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    bool allQuestionsAnswered = true;

    final pertanyaanList = (await futurePertanyaan).data;

    for (var pertanyaan in pertanyaanList) {
      if (!selectedAnswers.containsKey(pertanyaan.id) ||
          selectedAnswers[pertanyaan.id] == null) {
        allQuestionsAnswered = false;
        break;
      }
    }

    setState(() {
      hasError = !allQuestionsAnswered;
    });

    if (!allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Text("Tolong isi semua pertanyaan dengan lengkap."),
        ),
      );
      return;
    }

    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    // Kumpulkan data untuk dikirim
    Map<String, dynamic> body = {
      "karyawan_id": widget.currUser.id,
      "summary_id": widget.konseling.id,
      "nama_psikolog": widget.konseling.name,
      "feedback": selectedAnswers.entries.map((entry) {
        return {
          "soal_feedback_id": entry.key,
          "jawaban": entry.value ?? 0,
        };
      }).toList(),
    };

    print("Body yang akan dikirim: $body");

    try {
      final response = await http.post(
        Uri.parse('http://app.fagetti.com/api/konseling/feedback'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
        body: jsonEncode(body),
      );

      print("Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Text("Konseling berhasil dikirim"),
          ),
        );

        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => KonselingScreen(
                    currUser: widget.currUser,
                  )),
        );
      } else {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: Text("Konseling gagal dikirim"),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error $e');
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Text("Terjadi kesalahan saat mengirim data"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Karyawan user = widget.currUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        title: Text('Feedback Form', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<FeedbackQuestion>(
        future: futurePertanyaan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showDialog(context);
            });
            return Center(child: Text("No questions available."));
          }

          final pertanyaanList = snapshot.data!.data;

          return FormBuilder(
            key: _formKey,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pertanyaanList.length,
              itemBuilder: (context, index) {
                final pertanyaanfeedback = pertanyaanList[index];
                bool isAnswered =
                    selectedAnswers.containsKey(pertanyaanfeedback.id) &&
                        selectedAnswers[pertanyaanfeedback.id] != null;

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
                              color: hasError && !isAnswered
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pertanyaanfeedback.pertanyaanfeedback,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: hasError && !isAnswered
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.justify,
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
                              title: Text('$i'),
                              value: i,
                              activeColor: Colors.black,
                              groupValue:
                                  selectedAnswers[pertanyaanfeedback.id],
                              onChanged: (value) {
                                setState(() {
                                  selectedAnswers[pertanyaanfeedback.id] =
                                      value;
                                });
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF585858).withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          height: 125,
          color: Colors.white24,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 175,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            Colors.blue, // Ganti dengan warna yang sesuai
                      ),
                      onPressed: () async {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Kamu yakin mengirim konseling?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Data akan dikirim ke Psikolog.",
                                  style: TextStyle(
                                    color: const Color(0xFF585858),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  "Jika disetujui, tidak bisa diubah",
                                  style: TextStyle(
                                    color: const Color(0xFF585858),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Cek dulu deh'),
                                  ),
                                  TextButton(
                                    onPressed: _onSubmitKonselingBtnPress,
                                    child: Text('Yakin dong'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Buat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

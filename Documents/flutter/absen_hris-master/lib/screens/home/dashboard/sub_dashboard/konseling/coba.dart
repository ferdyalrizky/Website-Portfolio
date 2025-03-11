import 'dart:convert';
import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/jam_konseling.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/models/konseling_date.dart';
import 'package:hris_v2/models/response_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_conseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_field.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_keluhan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/konseling.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';
import '../../../../../models/pertanyaan_konseling.dart';

class FormKonselingScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormKonselingScreen({Key? key, required this.currUser})
      : super(key: key);

  @override
  State<FormKonselingScreen> createState() => _FormKonselingScreenState();
}

class _FormKonselingScreenState extends State<FormKonselingScreen> {
  String timeToShowDatePicker = "Klik untuk memilih tanggal";
  Timer? _timer;
  late TextEditingController emailController; // Declare the controller
  late TextEditingController keluhanController;
  Map<DateTime, bool> dateStatusMap = {};
  bool _isChecked = false;
  int _currentPage = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> locations = [];
  String? selectedLocation;
  Map<int, int?> selectedAnswers = {};
  late Future<PertanyaanResponse> futurePertanyaan;
  late List<int?> selectedAnswerIndex;
  int score = 0;

  final PageController _pageController = PageController();
  List<DateTime> availableDates = [];
  List<String> jamKonseling = [];
  String? selectedJam;
  String? email;
  String? keluhan;
  DateTime tglPertemuan = DateTime.now();
  double progress = 0;

  Future<List<String>> fetchLocations() async {
    final response = await http
        .get(Uri.parse('http://app.fagetti.com/api/konseling/lokasi'));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<String> locations = (jsonData['data'] as List)
          .map((location) => location['name'] as String)
          .toList();
      return locations;
    } else {
      throw Exception('Failed to load locations');
    }
  }

  _onSubmitSikBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    bool allQuestionsAnswered = true;

    // Ambil semua pertanyaan dari futurePertanyaan
    final pertanyaanList = (await futurePertanyaan).data;

    for (var pertanyaan in pertanyaanList) {
      if (!selectedAnswers.containsKey(pertanyaan.id) ||
          selectedAnswers[pertanyaan.id] == null) {
        allQuestionsAnswered = false;
        break; // Exit the loop if any question is unanswered
      }
    }

    // If not all questions are answered, show a notification
    if (!allQuestionsAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Gagal",
            msg: "Tolong isi semua pertanyaan dengan lengkap.",
            contentType: ContentType.failure,
          ),
        ),
      );
      return; // Stop execution if there are unanswered questions
    }

    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    if (tglPertemuan != null) {
      String mulaiTgl = DateFormat('yyyy-MM-dd').format(tglPertemuan);
      print("Tanggal yang akan dikirim: $mulaiTgl");
    } else {
      print("tglPertemuan adalah null, tidak dapat mengonversi tanggal.");
    }

    // Kumpulkan data untuk dikirim
    String mulaiTgl = DateFormat('yyyy-MM-dd').format(tglPertemuan);
    String jam = selectedJam ?? "";

    String email = emailController.text;
    String keluhan = keluhanController.text;
    String lokasi = selectedLocation ?? "";

    print("Email: $email");
    print("Keluhan: $keluhan");

    Map<String, dynamic> body = {
      "karyawan_id": widget.currUser.id,
      "tanggal": mulaiTgl,
      "jam": jam,
      "lama_kerja": "0", // Pastikan ini sesuai
      "email": email,
      "lokasi": lokasi, // Pastikan lokasi diatur
      "keluhan": keluhan,
      "summary": selectedAnswers.entries.map((entry) {
        return {
          "soal_id": entry.key,
          "jawaban": entry.value ?? 0,
        };
      }).toList(),
    };
    print("Tanggal Pertemuan: $tglPertemuan");
    // Debugging output
    print("Body yang akan dikirim: $body");

    try {
      final response = await http.post(
        Uri.parse('http://app.fagetti.com/api/konseling'),
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
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Konseling berhasil dikirim",
              contentType: ContentType.success,
            ),
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
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Konseling gagal dikirim",
              contentType: ContentType.failure,
            ),
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
          content: CustomSnackbarContent(
            title: "Error",
            msg: "Terjadi kesalahan saat mengirim data",
            contentType: ContentType.failure,
          ),
        ),
      );
    }
  }

  Future<void> fetchKonselingDates() async {
    final response = await http
        .get(Uri.parse('http://app.fagetti.com/api/konseling/tanggal-baru'));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      StatusResponse statusResponse = StatusResponse.fromJson(jsonData);
      print("API Response: $statusResponse");

      // Filter tanggal yang aktif
      List<DateTime> activeDates = statusResponse.data
          .where((dateStatus) => dateStatus.status == 'active')
          .map((dateStatus) => dateStatus.date)
          .toList();

      // Periksa jam untuk setiap tanggal
      for (var date in activeDates) {
        try {
          final jamResponse =
              await fetchJamKonseling(DateFormat('yyyy-MM-dd').format(date));
          bool hasActiveJam =
              jamResponse.data.any((jam) => jam.status == 'active');

          // Jika semua jam inactive, tanggal dianggap inactive
          if (!hasActiveJam) {
            dateStatusMap[date] = false;
          } else {
            dateStatusMap[date] = true;
          }
        } catch (e) {
          print("Error fetching jam for date $date: $e");
          dateStatusMap[date] =
              false; // Jika terjadi error, anggap tanggal inactive
        }
      }

      // Update availableDates hanya dengan tanggal yang active
      setState(() {
        availableDates =
            activeDates.where((date) => dateStatusMap[date] == true).toList();
      });
    } else {
      throw Exception('Failed to load dates');
    }
  }

  void _showDatePicker() {
    setState(() {
      timeToShowDatePicker =
          "Tunggu sebentar, pemilih tanggal sedang dibuka...";
    });

    // Simulasi penundaan sebelum menampilkan pemilih tanggal
    Future.delayed(Duration(seconds: 1), () {
      DateTime firstDate = DateTime.now();
      DateTime lastDate =
          firstDate.add(Duration(days: 365)); // 1 tahun ke depan

      showDatePicker(
        context: context,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDate: tglPertemuan,
      ).then((value) {
        if (value != null) {
          setState(() {
            tglPertemuan = value; // Set tanggal yang dipilih
            timeToShowDatePicker =
                "Tanggal dipilih: ${DateFormat('dd-MM-yyyy').format(tglPertemuan)}"; // Update teks
          });
        } else {
          setState(() {
            timeToShowDatePicker =
                "Klik untuk memilih tanggal"; // Reset teks jika tidak ada tanggal yang dipilih
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Pastikan timer dibatalkan saat widget dibuang
    super.dispose();
  }

  bool _isDateSelectable(DateTime date) {
    return availableDates.any((activeDate) =>
        activeDate.year == date.year &&
        activeDate.month == date.month &&
        activeDate.day == date.day);
  }

  @override
  void initState() {
    super.initState();
    futurePertanyaan = fetchPertanyaan();
    emailController = TextEditingController();
    keluhanController = TextEditingController();
    fetchKonselingDates();
    fetchLocations().then((value) {
      setState(() {
        locations = value;
      });
    });
  }

  Future<JamResponse> fetchJamKonseling(String tanggal) async {
    final response = await http.get(Uri.parse(
        'http://app.fagetti.com/api/konseling/jam-baru?tanggal=$tanggal'));
    if (response.statusCode == 200) {
      return JamResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load jam konseling');
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      tglPertemuan = date; // Set tanggal yang dipilih
    });
    _fetchJamKonseling(date); // Ambil jam berdasarkan tanggal yang dipilih
  }

  void _fetchJamKonseling(DateTime selectedDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    fetchJamKonseling(formattedDate).then((response) {
      setState(() {
        jamKonseling = response.data
            .where((jam) => jam.status == 'active')
            .map((jam) => jam.name)
            .toList();

        if (jamKonseling.isEmpty) {
          selectedJam = selectedJam; // Reset pilihan jam
        }
      });
    }).catchError((error) {
      print("Error fetching jam konseling: $error");
    });
  }

  void _nextPage() {
    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      // Retrieve email and keluhan values
      String email = emailController.text;
      String keluhan = keluhanController.text;

      // Check if email and keluhan are empty

      print("Email: $email");
      print("Keluhan: $keluhan");

      if (keluhan == null || keluhan.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Keluhan tidak boleh kosong."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If validation is successful, navigate to the next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<PertanyaanResponse> fetchPertanyaan() async {
    final response = await http.get(Uri.parse('$API_URL/konseling/pertanyaan'));

    if (response.statusCode == 200) {
      return PertanyaanResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load pertanyaan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 80,
      ),
      body: FutureBuilder<PertanyaanResponse>(
        future: futurePertanyaan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return Center(child: Text("No questions available"));
          }

          final pertanyaanList = snapshot.data!.data;

          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: FormBuilder(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update current page
                  });
                },
                children: [
                  SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            "Konseling",
                            style: TextStyle(
                              color: Color(0xFF121212),
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomTextAreaKonseling(
                            header: "Email*",
                            textAreaName: "email",
                            isRequired: true,
                            isEnabled: true,
                            controller: emailController, // Pass the controller
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 3.0),
                            child: const Text("Tanggal Pertemuan",
                                style: TextStyle(
                                  color: Color(0xFF000000),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 3.0, right: 2.0, bottom: 10),
                            width: 500,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // Tambahkan warna latar belakang
                              border: Border.all(
                                  color: const Color(0xFF1A1A1A), width: 1.0),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _showDatePicker();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Gunakan transparent agar border terlihat
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(tglPertemuan),
                                    style: TextStyle(
                                        color: Colors.grey[800], fontSize: 16),
                                  ),
                                  const Icon(Icons.calendar_month,
                                      color: Color(0xFF000000)),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            timeToShowDatePicker,
                            style: TextStyle(
                              color: Colors.grey[600], // Warna teks
                              fontSize: 14, // Ukuran teks
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomDropdownConseling(
                            header: "Jam Konseling",
                            dropdownName: "jam-konseling",
                            items: jamKonseling,
                            selectedValue: selectedJam,
                            onChanged: (value) {
                              setState(() {
                                selectedJam = value; // Set jam yang dipilih
                              });
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomDropdownField(
                            header: "Lokasi Konseling",
                            dropdownName: "lokasi",
                            items: locations,
                            selectedValue: selectedLocation,
                            onChanged: (value) {
                              setState(() {
                                selectedLocation =
                                    value; // Update the selected location
                              });
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          CustomTextKeluhan(
                            header: "Keluhan Umum*",
                            textAreaName: "keluhan",
                            labelText: "Tulis Keluhan Umum anda",
                            isRequired: true,
                            isEnabled: true,
                            controller: keluhanController,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pertanyaanList.length,
                          itemBuilder: (context, index) {
                            final pertanyaan = pertanyaanList[index];
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pertanyaan.pertanyaan,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(4, (i) {
                                      return Expanded(
                                        child: RadioListTile<int>(
                                          title: Text('${i + 1}'),
                                          value: i,
                                          groupValue:
                                              selectedAnswers[pertanyaan.id],
                                          onChanged: (value) {
                                            setState(() {
                                              selectedAnswers[pertanyaan.id] =
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 125,
        color: Colors.white24,
        child: Column(
          children: [
            if (_currentPage == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.black,
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false; // Update status checkbox
                      });
                    },
                  ),
                  Text(
                    'Saya menyetujui syarat dan ketentuan',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
            if (_currentPage == 0) ...[
              SizedBox(
                height: 35,
              ),
            ],
            SizedBox(
              width: 500.w,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: LightColors.kFagettiBlue,
                ),
                onPressed: (_currentPage == 1 && !_isChecked)
                    ? null
                    : () {
                        if (_currentPage == 0) {
                          _nextPage(); // Pindah ke halaman pertanyaan
                        } else {
                          _onSubmitSikBtnPress(); // Kirim data
                        }
                      },
                child: Text(
                  _currentPage == 0
                      ? 'Next'
                      : 'Kirim', // Tampilkan 'Next' atau 'Kirim'
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

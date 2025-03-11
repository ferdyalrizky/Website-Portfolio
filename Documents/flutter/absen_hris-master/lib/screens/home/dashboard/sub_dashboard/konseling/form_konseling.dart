import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_v2/models/jam_konseling.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/models/konseling_date.dart';
import 'package:hris_v2/models/response_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_conseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_field.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_konseling.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_keluhan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/konseling/konseling.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';

class FormKonselingScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormKonselingScreen({Key? key, required this.currUser})
      : super(key: key);

  @override
  State<FormKonselingScreen> createState() => _FormKonselingScreenState();
}

class _FormKonselingScreenState extends State<FormKonselingScreen> {
  late TextEditingController emailController; // Declare the controller
  late TextEditingController keluhanController;
  Map<DateTime, bool> dateStatusMap = {};
  bool isDateReady = false;
  bool _isChecked = false;
  bool hasError = false;
  int _currentPage = 0;

  bool _showButton = false;
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> locations = [];
  String? selectedLocation;
  Map<int, int?> selectedAnswers = {};
  late Future<PertanyaanResponse> futurePertanyaan;
  late List<int?> selectedAnswerIndex;
  int score = 0;

  final PageController _pageController = PageController();
  late Set<DateTime> availableDates = {};
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

  _onSubmitKonselingBtnPress() async {
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

    setState(() {
      hasError = !allQuestionsAnswered;
    });

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
          dateStatusMap[date] = hasActiveJam;
        } catch (e) {
          print("Error fetching jam for date $date: $e");
          dateStatusMap[date] =
              false; // Jika terjadi error, anggap tanggal inactive
        }
      }

      // Update availableDatesSet hanya dengan tanggal yang active
      setState(() {
        availableDates =
            activeDates.where((date) => dateStatusMap[date] == true).toSet();
        isDateReady = true;
      });
    } else {
      throw Exception('Failed to load dates');
    }
  }

  void _showDatePicker() {
    print("Date Picker Button Clicked");

    DateTime firstDate = DateTime.now();
    DateTime lastDate = firstDate.add(Duration(days: 100)); // 1 year ahead

    // Ensure initialDate is within the allowed range
    DateTime initialDate = availableDates.isNotEmpty
        ? availableDates.firstWhere((date) => !date.isBefore(firstDate),
            orElse: () =>
                availableDates.first // Fallback to the first available date
            )
        : firstDate;

    // Check if the initialDate is selectable
    bool _isDateSelectable(DateTime date) {
      // Check if the date is in the availableDatesSet
      return availableDates.contains(date);
    }

    showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
      selectableDayPredicate: _isDateSelectable,
    ).then((value) {
      if (value != null) {
        setState(() {
          tglPertemuan = value;
        });
        _fetchJamKonseling(value);
      }
    });
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
    fetchKonselingDates();
    emailController = TextEditingController();
    keluhanController = TextEditingController();

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
      if (keluhan.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Keluhan tidak boleh kosong."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if Tanggal Pertemuan, Jam Konseling, and Lokasi Konseling are filled
      if (tglPertemuan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tanggal Pertemuan harus diisi."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedJam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Jam Konseling harus diisi."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lokasi Konseling harus diisi."),
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<PertanyaanResponse> fetchPertanyaan() async {
    const int maxRetries = 5; // Jumlah maksimum percobaan
    int attempt = 0;

    final prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('pertanyaan_cache');
    if (cachedData != null) {
      return PertanyaanResponse.fromJson(json.decode(cachedData));
    }

    while (attempt < maxRetries) {
      try {
        final response =
            await http.get(Uri.parse('$API_URL/konseling/pertanyaan'));

        if (response.statusCode == 200) {
          await prefs.setString('pertanyaan_cache', response.body);
          return PertanyaanResponse.fromJson(json.decode(response.body));
        } else if (response.statusCode == 429) {
          attempt++;
          int waitTime =
              (1 << attempt); // Waktu tunggu eksponensial (2^attempt)
          print(
              'Rate limit exceeded. Attempt $attempt of $maxRetries. Retrying in $waitTime seconds...');
          await Future.delayed(Duration(seconds: waitTime));
        } else {
          throw Exception('Failed to load questions: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching questions: $e');
        if (cachedData != null) {
          return PertanyaanResponse.fromJson(json.decode(cachedData));
        }
        return PertanyaanResponse.defaultResponse();
      }
    }

    throw Exception('Max retries exceeded for fetching questions');
  }

  void _petunjukpengisian() {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 380.w,
              height: 575.w,
              padding: EdgeInsets.all(24.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Petunjuk pengisian",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            "Kuesioner ini terdiri dari berbagai pernyataan yang mungkin sesuai dengan pengalaman Bapak/Ibu/Saudara dalam menghadapi situasi hidup sehari-hari.Selanjutnya, Bapak/Ibu/Saudara diminta untuk menjawab pilihan yang paling sesuai dengan pengalaman Bapak/Ibu/Saudara selama satu minggu belakangan ini.\n\n"
                            "Tidak ada jawaban yang benar ataupun salah, karena itu isilah sesuai dengan keadaan diri Bapak/Ibu/Saudara yang sesungguhnya. Jangan menghabiskan waktu terlalu banyak pada pernyataan apapun, silakan pilih berdasarkan jawaban pertama yang terlintas dalam benak Bapak/Ibu/Saudara.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _syaratdanketentuan() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 1,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0))),
            padding: const EdgeInsets.all(8).w,
            child: ListView(controller: controller, children: [
              SizedBox(
                height: 25.h,
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Syarat dan ketentuan",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Text(
                            "Pendahuluan",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Adalah penting bagi saya sebagai klein yang baru akan mengikuti layanan konseling/psikoterapi dengan psikolog untuk mengetahui dan memahami beberapa hal penting dari sesi yang akan dijalani sebelum memulainya.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "1. Psikolog",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Psikolog adalah tenaga profesional di bidang kesehatan mental yang akan membantu para klien untuk mengatasi permasalahan mereka menggunakan berbagai jenis penanganan atau psikoterapi. Psikolog yang berpraktik sudah memiliki lisensi atau izin praktik sebagai psikolog di Indonesia yang dikeluarkan oleh Himpunan Psikologi Indonesia (HIMPSI).\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "2. Tujuan Konseling dan Psikoterapi ",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "konseling",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          Text(
                            "Saya memahami bahwa layanan konseling bertujuan untuk membantu saya dalam memahami, mengelola, dan mencari solusi atas permasalahan yang saya hadapi, baik terkait dengan pekerjaan maupun aspek pribadi yang berdampak pada kesejahteraan saya di tempat kerja. Konseling berfokus pada dukungan emosional, bimbingan, dan pemberdayaan diri dalam menghadapi tantangan sehari-hari.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "Psikoterapi",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                          Text(
                            "Psikoterapi adalah proses yang lebih mendalam yang bertujuan untuk memahami pola pikir, perasaan, dan perilaku yang mendasari masalah psikologis yang saya alami. Layanan ini membantu dalam mengidentifikasi akar permasalahan, mengembangkan strategi penanganan, dan meningkatkan kesejahteraan mental dalam jangka panjang.\n\n"
                            "Sama seperti penanganan medis, layanan konseling/psikoterapi juga bisa menimbulkan ketidaknyamanan pada diri saya selama prosesnya karena mungkin melibatkan pembahasan mengenai isu-isu atau topik yang bisa memunculkan emosi-emosi negatif yang tidak menyenangkan, seperti rasa marah, malu, bersalah, atau yang lainnya. Saya memiliki hak untuk mengundurkan diri dari proses ini kapan saja, namun diharapkan keputusan tersebut diambil setelah mendiskusikannya dengan psikolog.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "3. Kerahasiaan",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Saya memahami bahwa semua informasi yang saya sampaikan selama sesi konseling bersifat rahasia, kecuali dalam situasi berikut:\n"
                            "a. Jika saya memberikan izin tertulis untuk membagikan informasi tertentu.\n"
                            "b. Jika terdapat ancaman serius terhadap keselamatan diri saya atau orang lain.\n"
                            "c. Jika diwajibkan oleh hukum atau kebijakan perusahaan.\n"
                            "Jika kondisi-kondisi seperti itu terjadi, maka adalah kewajiban psikolog untuk menjamin keamanan dan keselamatan saya dan lingkungan sekitarnya sebagai prioritas utama.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "4. Hak dan Tanggung Jawab Klien",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Sebagai klien, saya berhak untuk:\n"
                            "Mendapatkan layanan konseling dan psikoterapi yang profesional dan menghormati martabat saya.\n"
                            "b. Mengajukan pertanyaan dan meminta klarifikasi terkait proses konseling dan psikoterapi.\n"
                            "c. Menghentikan layanan kapan saja dengan memberikan pemberitahuan sebelumnya\n\n"
                            "Saya juga bertanggung jawab untuk:\n"
                            "a. Bersikap jujur dan terbuka selama sesi konseling.\n"
                            "b. Menghormati jadwal sesi yang telah disepakati dan memberikan pemberitahuan jika perlu membatalkan atau menjadwalkan ulang sesi.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "5. Proses Konseling dan Psikoterapi",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Saya memahami bahwa layanan konseling dan psikoterapi dapat dilakukan dalam berbagai format, termasuk tatap muka atau online, sesuai dengan kesepakatan antara saya dan psikolog.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "6. Batasan Layanan Konseling dan Psikoterapi",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Jika psikolog menilai bahwa saya memiliki masalah atau kondisi yang membutuhkan penanganan psikologis yang berada di luar penguasaannya, maka psikolog akan mendiskusikannya secara terbuka dengan saya dan memastikan bahwa saya menerima rujukan ke profesional lain yang lebih kompeten dan memenuhi syarat untuk membantu dan memberikan penanganan yang dibutuhkan klien.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                          Text(
                            "7. Persetujuan",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            "Saya telah membaca dan memahami informasi di atas. Dengan menandatangani dokumen ini, saya menyatakan bahwa saya secara sukarela memberikan persetujuan untuk menerima layanan konseling dan memahami hak serta tanggung jawab saya sebagai klien.\n",
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Radius sudut
          ),
          content: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            width: double.infinity,
            height: 350.h, // Ganti dengan ukuran yang sesuai
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/menunggu_kuisioner.svg'),
                Text(
                  "Mohon Menunggu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  "Sementara kuesioner sedang dimuat",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                Text(
                  "silahkan kembali ke halaman sebelumnya.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          actions: <Widget>[
            SizedBox(
              height: 50.h,
              width: 500.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: LightColors
                      .kFagettiBlue, // Ganti dengan warna yang sesuai
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => KonselingScreen(
                              currUser: widget.currUser,
                            )),
                  );
                },
                child: Text(
                  "Kembali",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60,
      ),
      body: FutureBuilder<PertanyaanResponse>(
        future: futurePertanyaan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            Future.microtask(() => _showDialog(context));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showDialog(context);
            });
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
                physics: NeverScrollableScrollPhysics(),
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
                            child: const Text("Tanggal Pertemuan*",
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
                              color: Colors.white,
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
                          const SizedBox(
                            height: 15,
                          ),
                          CustomDropdownConseling(
                            header: "Jam Konseling*",
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
                            header: "Lokasi Konseling*",
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
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kuisioner",
                                style: TextStyle(
                                  fontSize: 21.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pilihan",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap:
                                        _petunjukpengisian, // Show info dialog on tap
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 26, // Adjust size as needed
                                      color: Colors
                                          .black, // Change color if desired
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "0: Tidak sesuai",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF585858),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.h,
                                      ),
                                      Text(
                                        "1: Agak sesuai",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF585858),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 60.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "2: Sesuai",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF585858),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.h,
                                      ),
                                      Text(
                                        "3: Sangat sesuai",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF585858),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15.h,
                              ),
                              Container(
                                height: 1,
                                width: 500,
                                color: Color(0xFFDBDBDB),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pertanyaanList.length,
                          itemBuilder: (context, index) {
                            final pertanyaan = pertanyaanList[index];
                            bool isAnswered =
                                selectedAnswers.containsKey(pertanyaan.id) &&
                                    selectedAnswers[pertanyaan.id] != null;
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Menyelaraskan bagian atas
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
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // Menyelaraskan teks ke kiri
                                          children: [
                                            Text(
                                              pertanyaan.pertanyaan,
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
                                          title: Text('${i}'),
                                          value: i,
                                          activeColor: Colors.black,
                                          groupValue:
                                              selectedAnswers[pertanyaan.id],
                                          onChanged: (value) {
                                            setState(() {
                                              selectedAnswers[pertanyaan.id] =
                                                  value ?? 0;
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF585858).withOpacity(0.15), // Warna bayangan
              spreadRadius: 2, // Jarak penyebaran bayangan
              blurRadius: 5, // Seberapa kabur bayangan
              offset: Offset(0, -2), // Posisi bayangan (hanya di atas)
            ),
          ],
        ),
        child: BottomAppBar(
          height: 125,
          color: Colors.white24,
          child: Column(
            children: [
              if (_currentPage == 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      'Saya menyetujui ', // Static text
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: _syaratdanketentuan, // Show dialog on tap
                      child: Text(
                        'syarat dan ketentuan', // Clickable text
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
              if (_currentPage == 0) ...[
                SizedBox(
                  height: 35,
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Menyelaraskan semua elemen di tengah
                children: [
                  // Tampilkan tombol Back hanya di halaman kedua
                  if (_currentPage == 1) ...[
                    SizedBox(
                      width: 175.w,
                      height: 55.h,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.black, // Warna border hitam
                                width: 1, // Ketebalan border 1
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.white, // Warna tombol Back
                          ),
                          onPressed: () {
                            _previousPage(); // Panggil fungsi untuk kembali ke halaman sebelumnya
                          },
                          child: Text(
                            "Kembali",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                  ],
                  SizedBox(width: 10.w),
                  // Tombol Next
                  if (_currentPage == 0) ...[
                    SizedBox(
                      width: 375.w, // Ukuran tombol Next
                      height: 55.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: LightColors.kFagettiBlue,
                        ),
                        onPressed: () {
                          _nextPage(); // Pindah ke halaman pertanyaan
                        },
                        child: Text(
                          'Next', // Teks tombol Next
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Tombol Kirim
                  if (_currentPage == 1) ...[
                    SizedBox(
                      width: 175.w,
                      height: 55.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: LightColors.kFagettiBlue,
                        ),
                        onPressed: (_currentPage == 1 && !_isChecked)
                            ? null
                            : () async {
                                showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Kamu yakin mengirim konseling?',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          "Data akan dikirim ke Psikolog.",
                                          style: TextStyle(
                                            color: const Color(0xFF585858),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          "Jika disetujui, tidak bisa diubah",
                                          style: TextStyle(
                                            color: const Color(0xFF585858),
                                            fontSize: 14.sp,
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
                                          SizedBox(
                                            width: 131.w,
                                            height: 40.r,
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              style: TextButton.styleFrom(
                                                side: const BorderSide(
                                                    color: Colors.black),
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Cek dulu deh',
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF142638),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          SizedBox(
                                            width: 120.w,
                                            height: 40.h,
                                            child: TextButton(
                                              onPressed:
                                                  _onSubmitKonselingBtnPress,
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    LightColors.kFagettiBlue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                'Yakin dong',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

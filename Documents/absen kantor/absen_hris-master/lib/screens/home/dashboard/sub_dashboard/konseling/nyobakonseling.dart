import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime_range_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

class FormKonselingScreen extends StatefulWidget {
  final Karyawan currUser;

  const FormKonselingScreen({Key? key, required this.currUser})
      : super(key: key);

  @override
  State<FormKonselingScreen> createState() => _FormKonselingScreenState();
}

class _FormKonselingScreenState extends State<FormKonselingScreen> {
  final PageController _pageController = PageController();
  final _formKey1 = GlobalKey<FormBuilderState>();
  final _formKey2 = GlobalKey<FormBuilderState>();

  void _nextPage() {
    if (_formKey1.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _submitForm() {
    if (_formKey2.currentState!.validate()) {
      // Lakukan pengiriman data ke server
      _onSubmitSikBtnPress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Konseling'),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          // Step 1
          SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FormBuilder(
                  key: _formKey1,
                  initialValue: {
                    'pembuat': widget.currUser.namaKaryawan,
                    'divisi-pembuat':
                        widget.currUser.divisiId ?? "Divisi not define",
                    "jenis-tidak-hadir": "Sakit",
                    "jumlah-cuti": widget.currUser.jatahCuti.toString(),
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Pengajuan Sakit",
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomTextFieldAndHeader(
                        header: "Nama Karyawan",
                        txtFieldName: "pembuat",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomDateTimeRangeAndHeader(
                        header: "Tanggal Mulai - Selesai Sakit",
                        dateTimeName: "range-sakit",
                        isRequired: true,
                      ),
                      ElevatedButton(
                        onPressed: _nextPage,
                        child: Text("Next"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Step 2
          SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FormBuilder(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Keterangan Sakit",
                        style: TextStyle(
                          color: Color(0xFF121212),
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomTextAreaAndHeader(
                        header: "Keterangan",
                        textAreaName: "keterangan-sakit",
                        labelText: "Tulis Keterangan Sakit Anda",
                        isRequired: true,
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text("Kirim"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmitSikBtnPress() {
    // Implementasi pengiriman data ke server
  }
}

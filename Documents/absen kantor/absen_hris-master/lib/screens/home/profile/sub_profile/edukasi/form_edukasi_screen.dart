import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import '../../../dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

class FormEdukasiScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormEdukasiScreen({super.key, required this.currUser});

  @override
  State<FormEdukasiScreen> createState() => _FormEdukasiScreenState();
}

class _FormEdukasiScreenState extends State<FormEdukasiScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isGetDataPendidikan = false;
  List<String> jenjang = ['SD', 'SMP', 'SMA', 'D3', 'D4', 'S1', 'S2', 'S3'];
  String namaInstansi = "";
  String selectedJenjang = "";
  String jurusan = "";
  int tahunMasuk = 0;
  int tahunLulus = 0;

  _onGetDataPendidikan() async {
    setState(() {
      isGetDataPendidikan = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getPendidikanData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      setState(() {
        namaInstansi = output['nama_instansi'];
        selectedJenjang = output['jenjang_pendidikan'] ?? 'SD';
        jurusan = output['jurusan'];
        tahunMasuk = output['tahun_masuk'];
        tahunLulus = output['tahun_lulus'];
      });
    } catch (e) {
      debugPrint('error $e');
    }

    setState(() {
      isGetDataPendidikan = false;
    });
  }

  _onUpdateBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    Map<String, String> body = {
      "nama_instansi": _formKey.currentState?.fields['nama_instansi']?.value,
      "jenjang_pendidikan": _formKey.currentState?.fields['jenjang']?.value,
      "jurusan": _formKey.currentState?.fields['jurusan']?.value,
      "tahun_masuk": _formKey.currentState?.fields['tahun_masuk']?.value,
      "tahun_lulus": _formKey.currentState?.fields['tahun_lulus']?.value,
    };

    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$API_URL/v2/updatePendidikanData/${widget.currUser.id}'))
        ..headers.addAll(header)
        ..fields.addAll(body);

      var response = await request.send();
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Update Data Edukasi Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        _onGetDataPendidikan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Update Data Edukasi Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  @override
  void initState() {
    _onGetDataPendidikan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text("Data Edukasi", style: TextStyle(color: Colors.white)),
        actions: const [],
        backgroundColor: LightColors.kFagettiBlue,
      ),
      body: isGetDataPendidikan
          ? const Center(
              child: Loader(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    "nama_instansi": namaInstansi,
                    "jurusan": jurusan,
                    "tahun_masuk": tahunMasuk.toString(),
                    "tahun_lulus": tahunLulus.toString(),
                    "jenjang": selectedJenjang,
                  },
                  child: Column(
                    children: [
                      const CustomTextFieldAndHeader(
                        header: "Nama Instansi",
                        txtFieldName: "nama_instansi",
                        keyboardType: TextInputType.name,
                        isRequired: true,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Jurusan",
                        txtFieldName: "jurusan",
                        keyboardType: TextInputType.name,
                        isRequired: true,
                      ),
                      CustomDropdownAndHeader(
                        header: "Jenjang",
                        dropdownName: "jenjang",
                        items: jenjang,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Tahun Masuk",
                        txtFieldName: "tahun_masuk",
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Tahun Lulus",
                        txtFieldName: "tahun_lulus",
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white24,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: LightColors.kFagettiBlue,
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
                      'Kamu yakin mengubah Data Edukasi?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Jika yakin, tidak bisa diubah",
                      style: TextStyle(
                        color: const Color(0xFF585858),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 131.w,
                        height: 40.r,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cek dulu deh',
                            style: TextStyle(
                              color: const Color(0xFF142638),
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
                          onPressed: _onUpdateBtnPress,
                          style: TextButton.styleFrom(
                            backgroundColor: LightColors.kFagettiBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
          child: const Text(
            'Update',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

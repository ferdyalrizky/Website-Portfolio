import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/utils/public_func.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

import '../../../../../models/keluarga.dart';
import '../../../../../theme/colors/light_colors.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';
import '../../../dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import '../../../dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

class ProfileKeluargaScreen extends StatefulWidget {
  final Karyawan currUser;
  const ProfileKeluargaScreen({super.key, required this.currUser});

  @override
  State<ProfileKeluargaScreen> createState() => _ProfileKeluargaScreenState();
}

class _ProfileKeluargaScreenState extends State<ProfileKeluargaScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  DateTime dobAnak1 = DateTime.now();
  DateTime dobAnak2 = DateTime.now();
  DateTime dobAnak3 = DateTime.now();

  bool isGetDataKeluarga = false;
  Keluarga keluargaData = Keluarga();
  final List<String> listStatusMenikah = [
    "Belum Menikah",
    "Menikah",
    "Janda/duda"
  ];

  void _showDatePickerDobAnak1() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 99),
      lastDate: DateTime(DateTime.now().year),
    ).then((value) {
      setState(() {
        dobAnak1 = value!;
      });
    });
  }

  void _showDatePickerDobAnak2() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 99),
      lastDate: DateTime(DateTime.now().year),
    ).then((value) {
      setState(() {
        dobAnak2 = value!;
      });
    });
  }

  void _showDatePickerDobAnak3() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 99),
      lastDate: DateTime(DateTime.now().year),
    ).then((value) {
      setState(() {
        dobAnak3 = value!;
      });
    });
  }

  _onGetDataKeluarga() async {
    setState(() {
      isGetDataKeluarga = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getKeluargaData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      keluargaData = Keluarga.fromJson(output);
      print(keluargaData.statusNikah);
    } catch (e) {
      debugPrint('error $e');
    }

    setState(() {
      isGetDataKeluarga = false;
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
    String? statusNikah = _formKey.currentState?.fields['status_menikah']?.value
        .toString()
        .toLowerCase();
    Map<String, String> body = {
      "status_nikah": statusNikah!,
      "nama_pasangan":
          _formKey.currentState?.fields['nama_pasangan']?.value ?? '',
      "nama_anak_1": _formKey.currentState?.fields['nama_anak_1']?.value ?? '',
      "nama_anak_2": _formKey.currentState?.fields['nama_anak_2']?.value ?? '',
      "nama_anak_3": _formKey.currentState?.fields['nama_anak_3']?.value ?? '',
      "nama_ayah": _formKey.currentState?.fields['nama_ayah']?.value ?? '',
      "no_hp_ayah": _formKey.currentState?.fields['no_hp_ayah']?.value ?? '',
      "nama_ibu": _formKey.currentState?.fields['nama_ibu']?.value ?? '',
      "no_hp_ibu": _formKey.currentState?.fields['no_hp_ibu']?.value ?? '',
      "nama_kontak_emergensi":
          _formKey.currentState?.fields['nama_kontak_emergensi']?.value ?? '',
      "hubungan_emergensi":
          _formKey.currentState?.fields['hubungan_kontak_emergensi']?.value ??
              '',
      "no_hp_emergensi":
          _formKey.currentState?.fields['no_hp_emergensi']?.value ?? '',
    };

    print(body);
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$API_URL/v2/updateKeluargaData/${widget.currUser.id}'))
        ..headers.addAll(header)
        ..fields.addAll(body);

      var response = await request.send();
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Update Data Keluarga Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        _onGetDataKeluarga();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Update Data Keluarga Gagal",
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
    _onGetDataKeluarga();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text("Data Keluarga", style: TextStyle(color: Colors.white)),
        backgroundColor: LightColors.kFagettiBlue,
        actions: const [],
      ),
      body: isGetDataKeluarga
          ? const Center(child: Loader())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    "status_menikah":
                        capitalizeAllWord(keluargaData.statusNikah!),
                    "nama_pasangan": keluargaData.namaPasangan,
                    "nama_anak_1": keluargaData.namaAnak1,
                    "nama_anak_2": keluargaData.namaAnak2,
                    "nama_anak_3": keluargaData.namaAnak3,
                    "nama_ayah": keluargaData.namaAyah,
                    "no_hp_ayah": keluargaData.noHpAyah,
                    "nama_ibu": keluargaData.namaIbu,
                    "no_hp_ibu": keluargaData.noHpIbu,
                    "nama_kontak_emergensi": keluargaData.namaKontakEmergensi,
                    "hubungan_kontak_emergensi": keluargaData.hubunganEmergensi,
                    "no_hp_emergensi": keluargaData.noHpEmergensi
                  },
                  child: Column(
                    children: [
                      CustomDropdownAndHeader(
                        header: "Status Menikah",
                        dropdownName: "status_menikah",
                        items: listStatusMenikah,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Nama Pasangan",
                        txtFieldName: "nama_pasangan",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Nama Anak 1",
                        txtFieldName: "nama_anak_1",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      // keluargaData.namaAnak1 != ""
                      //     ? Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             DateFormat('dd-MM-yyyy').format(
                      //                 DateTime.parse(keluargaData.dobAnak1!)),
                      //             style: const TextStyle(fontSize: 25),
                      //           ),
                      //           ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: CustomTheme.kFagettiBlue,
                      //             ),
                      //             onPressed: _showDatePickerDobAnak1,
                      //             child: const Text(
                      //                 "Pilih Tanggal Lahir Anak Pertama"),
                      //           )
                      //         ],
                      //       )
                      //     : Container(),
                      const CustomTextFieldAndHeader(
                        header: "Nama Anak 2",
                        txtFieldName: "nama_anak_2",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      // keluargaData.namaAnak2 != ""
                      //     ? Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             DateFormat('dd-MM-yyyy').format(
                      //                 DateTime.parse(keluargaData.dobAnak2!)),
                      //             style: const TextStyle(fontSize: 25),
                      //           ),
                      //           ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: CustomTheme.kFagettiBlue,
                      //             ),
                      //             onPressed: _showDatePickerDobAnak2,
                      //             child: const Text(
                      //                 "Pilih Tanggal Lahir Anak Kedua"),
                      //           )
                      //         ],
                      //       )
                      //     : Container(),
                      const CustomTextFieldAndHeader(
                        header: "Nama Anak 3",
                        txtFieldName: "nama_anak_3",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      // keluargaData.namaAnak3 != ""
                      //     ? Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             DateFormat('dd-MM-yyyy').format(
                      //                 DateTime.parse(keluargaData.dobAnak3!)),
                      //             style: const TextStyle(fontSize: 25),
                      //           ),
                      //           ElevatedButton(
                      //             style: ElevatedButton.styleFrom(
                      //               backgroundColor: CustomTheme.kFagettiBlue,
                      //             ),
                      //             onPressed: _showDatePickerDobAnak3,
                      //             child: const Text(
                      //                 "Pilih Tanggal Lahir Anak Ketiga"),
                      //           ),
                      //         ],
                      //       )
                      //     : Container(),
                      const CustomTextFieldAndHeader(
                        header: "Nama Ayah",
                        txtFieldName: "nama_ayah",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "No HP Ayah",
                        txtFieldName: "no_hp_ayah",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Nama Ibu",
                        txtFieldName: "nama_ibu",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "No HP Ibu",
                        txtFieldName: "no_hp_ibu",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Nama Kontak Darurat",
                        txtFieldName: "nama_kontak_emergensi",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "Hubungan Dengan Kontak Darurat",
                        txtFieldName: "hubungan_kontak_emergensi",
                        keyboardType: TextInputType.name,
                        isRequired: false,
                      ),
                      const CustomTextFieldAndHeader(
                        header: "No HP Darurat",
                        txtFieldName: "no_hp_emergensi",
                        keyboardType: TextInputType.name,
                        isRequired: false,
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
                      'Kamu yakin mengubah Data Keluarga?',
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

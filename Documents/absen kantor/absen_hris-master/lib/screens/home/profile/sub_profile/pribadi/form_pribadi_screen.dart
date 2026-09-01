import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/data_pribadi.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/widgets/loader.dart';

import '../../../../../models/karyawan.dart';

import 'package:http/http.dart' as http;

import '../../../../../theme/colors/light_colors.dart';
import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';

class FormProfilePribadiScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormProfilePribadiScreen({super.key, required this.currUser});

  @override
  State<FormProfilePribadiScreen> createState() =>
      _FormProfilePribadiScreenState();
}

class _FormProfilePribadiScreenState extends State<FormProfilePribadiScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  DataPribadi currUserDataPribadi = DataPribadi();
  bool isGetDataPribadi = false;
  List<String> listGender = ['laki-laki', 'perempuan'];

  _onGetDataPribadi() async {
    setState(() {
      isGetDataPribadi = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getPersonalData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      currUserDataPribadi = DataPribadi.fromJson(output);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      isGetDataPribadi = false;
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
      "nama_panggilan": _formKey.currentState?.fields['nama_panggilan']?.value,
      "nama_lengkap": _formKey.currentState?.fields['nama_lengkap']?.value,
      "gender": _formKey.currentState?.fields['gender']?.value,
      "email": _formKey.currentState?.fields['email']?.value,
      "alamat_ktp": _formKey.currentState?.fields['alamat_ktp']?.value,
      "alamat_domisili":
          _formKey.currentState?.fields['alamat_domisili']?.value,
      "no_ktp": _formKey.currentState?.fields['no_ktp']?.value,
      "no_kk": _formKey.currentState?.fields['no_kk']?.value,
      "bpjs_kes": _formKey.currentState?.fields['bpjs_kes']?.value,
      "bpjs_tk": _formKey.currentState?.fields['bpjs_tk']?.value,
      "npwp": _formKey.currentState?.fields['npwp']?.value,
      "nama_rekening": _formKey.currentState?.fields['nama_rekening']?.value,
      "no_rekening": _formKey.currentState?.fields['no_rekening']?.value,
      "id_karyawan": widget.currUser.id.toString(),
    };
    print('id karyawab : ${widget.currUser.id}');
    print(body);

    //Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$API_URL/v2/updatePersonalData/${currUserDataPribadi.id}'))
        ..headers.addAll(header)
        ..fields.addAll(body);
      var response = await request.send();
      if (response.statusCode == 201) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Update Data Pribadi Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        _onGetDataPribadi();
      } else {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Update Data Pribadi Gagal",
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
    _onGetDataPribadi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Data Pribadi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: LightColors.kFagettiBlue,
        actions: const [],
      ),
      body: isGetDataPribadi
          ? const Center(child: Loader())
          : SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: FormBuilder(
                    key: _formKey,
                    initialValue: {
                      'nama_lengkap': currUserDataPribadi.namaLengkap,
                      'nama_panggilan': currUserDataPribadi.namaPanggilan,
                      'gender': currUserDataPribadi.gender,
                      'email': currUserDataPribadi.email ?? "",
                      'alamat_ktp': currUserDataPribadi.alamatLengkap,
                      'alamat_domisili': currUserDataPribadi.alamatDomisili,
                      'no_ktp': currUserDataPribadi.noKtp ?? '',
                      'no_kk': currUserDataPribadi.noKk ?? '',
                      'bpjs_kes': currUserDataPribadi.bpjsKes,
                      'bpjs_tk': currUserDataPribadi.bpjsTk,
                      'npwp': currUserDataPribadi.npwp,
                      'nama_rekening': currUserDataPribadi.namaRek,
                      'no_rekening': currUserDataPribadi.noRek,
                    },
                    child: Column(
                      children: [
                        const CustomTextFieldAndHeader(
                          header: "Nama Lengkap",
                          txtFieldName: "nama_lengkap",
                          keyboardType: TextInputType.name,
                          isRequired: true,
                        ),
                        const CustomTextFieldAndHeader(
                          header: "Nama Panggilan",
                          txtFieldName: "nama_panggilan",
                          keyboardType: TextInputType.name,
                          isRequired: true,
                        ),
                        //TODO bikin date picker u/ tgl lahir
                        CustomDropdownAndHeader(
                          header: "Jenis Kelamin",
                          dropdownName: "gender",
                          items: listGender,
                        ),
                        CustomTextFieldAndHeader(
                          header: "Email",
                          txtFieldName: "email",
                          keyboardType: TextInputType.emailAddress,
                          isEnabled: currUserDataPribadi.email == null,
                          isRequired: true,
                        ),
                        CustomTextAreaAndHeader(
                          header: 'Alamat KTP',
                          textAreaName: "alamat_ktp",
                          isEnabled: currUserDataPribadi.alamatLengkap == null,
                          isRequired: true,
                        ),
                        CustomTextAreaAndHeader(
                          header: 'Alamat Domisili',
                          textAreaName: "alamat_domisili",
                          isEnabled: currUserDataPribadi.alamatDomisili == null,
                          isRequired: true,
                        ),
                        CustomTextFieldAndHeader(
                          header: 'No KTP',
                          txtFieldName: "no_ktp",
                          keyboardType: TextInputType.number,
                          isEnabled: currUserDataPribadi.noKtp == null,
                          isRequired: true,
                        ),
                        CustomTextFieldAndHeader(
                          header: 'No KK',
                          txtFieldName: "no_kk",
                          keyboardType: TextInputType.number,
                          isEnabled: currUserDataPribadi.noKk == null,
                          isRequired: true,
                        ),
                        const CustomTextFieldAndHeader(
                          header: 'No BPJS Kesehatan',
                          txtFieldName: "bpjs_kes",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        const CustomTextFieldAndHeader(
                          header: 'No BPJS Ketenagakerjaan',
                          txtFieldName: "bpjs_tk",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        const CustomTextFieldAndHeader(
                          header: 'NPWP',
                          txtFieldName: "npwp",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        CustomTextFieldAndHeader(
                          header: 'Nama Rekening',
                          txtFieldName: "nama_rekening",
                          keyboardType: TextInputType.name,
                          isEnabled: currUserDataPribadi.namaRek == null,
                        ),
                        CustomTextFieldAndHeader(
                          header: 'No Rekening',
                          txtFieldName: "no_rekening",
                          keyboardType: TextInputType.number,
                          isEnabled: currUserDataPribadi.noRek == null,
                        ),
                      ],
                    ),
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
                      'Kamu yakin mengubah Data Pribadi?',
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

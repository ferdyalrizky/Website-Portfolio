import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;

import '../../../../../utils/constant.dart';
import '../../../dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

class FormProfilePekerjaanScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormProfilePekerjaanScreen({super.key, required this.currUser});

  @override
  State<FormProfilePekerjaanScreen> createState() =>
      _FormProfilePekerjaanScreenState();
}

class _FormProfilePekerjaanScreenState
    extends State<FormProfilePekerjaanScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool getDataPekerjaan = false;
  String bisnis = "";
  String areaKerja = "";
  String department = "";

  onGetDataPekerjaan() async {
    setState(() {
      getDataPekerjaan = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$API_URL/v2/getPekerjaanData/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      setState(() {
        bisnis = output['bisnis'];
        areaKerja = output['area_kerja'];
        department = output['department'];
      });

      print('bisnis : $bisnis');
      print('areaKerja : $areaKerja');
      print('department : $department');
    } catch (e) {
      debugPrint('error $e');
    }

    setState(() {
      getDataPekerjaan = false;
    });
  }

  @override
  void initState() {
    onGetDataPekerjaan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Data Pekerjaan",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [],
        backgroundColor: LightColors.kFagettiBlue,
      ),
      body: getDataPekerjaan
          ? const Center(
              child: Loader(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'nip': widget.currUser.nip,
                    'perusahaan': bisnis,
                    'area_kerja': areaKerja,
                    'department': department,
                    'divisi': widget.currUser.divisi,
                    'job_title': widget.currUser.jobTitle,
                  },
                  child: const Column(
                    children: [
                      CustomTextFieldAndHeader(
                        header: "NIP",
                        txtFieldName: "nip",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomTextFieldAndHeader(
                        header: "Perusahaan",
                        txtFieldName: "perusahaan",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomTextFieldAndHeader(
                        header: "Area Kerja",
                        txtFieldName: "area_kerja",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomTextFieldAndHeader(
                        header: "Departemen",
                        txtFieldName: "department",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomTextFieldAndHeader(
                        header: "Divisi",
                        txtFieldName: "divisi",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                      CustomTextFieldAndHeader(
                        header: "Posisi",
                        txtFieldName: "job_title",
                        keyboardType: TextInputType.name,
                        isEnabled: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

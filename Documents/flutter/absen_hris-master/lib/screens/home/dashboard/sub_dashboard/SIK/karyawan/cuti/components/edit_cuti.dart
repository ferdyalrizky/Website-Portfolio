import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/cuti_normatif.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/cuti/list_sik_cuti_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_area_cuti.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime_range_and_header.dart';

import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import '../../../../../../../../models/karyawan.dart';

import 'package:hris_v2/widgets/custom_snackbar_content.dart';

import '../../../../../../../../models/sik.dart';

class EditCuti extends StatefulWidget {
  final Sik sik;
  final Karyawan currUser;
  final int jatahCutiUser;
  const EditCuti({
    super.key,
    required this.currUser,
    required this.jatahCutiUser,
    required this.sik,
  });

  @override
  State<EditCuti> createState() => _EditCutiState();
}

class _EditCutiState extends State<EditCuti> {
  DateTime tanggalIzin = DateTime.now();
  bool loadingGetCutiNormatif = true;
  List<CutiNormatif> listCutiNormatif = [];
  List<String> listNameCutiNormatif = ["Menikah"];
  String cutiNormatifTerpilih = "Menikah";
  List<String> listKategoriCuti = ["Cuti Tahunan", "Cuti Normatif"];
  String kategoriCutiTerpilih = "";
  int jatahCutiKaryawan = 0;
  int jumlahHariCuti = 0;

  int idCutiNormatifTerpilih = 0;
  int jatahCutiNormatifTerpilih = 0;

  final _formKey = GlobalKey<FormBuilderState>();

  _getCutiNormatifList() async {
    jatahCutiKaryawan = widget.jatahCutiUser;
    listCutiNormatif = [];
    listNameCutiNormatif = [];
    try {
      final response = await http.get(
        Uri.parse('$API_URL/v3/listCutiNormatif'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);

      for (var cn in output) {
        if (cn['bisnis_id'] == widget.currUser.bisnisId) {
          listCutiNormatif.add(CutiNormatif.fromJson(cn));
          listNameCutiNormatif.add(cn['cuti_normatif']);
        }
      }
      CutiNormatif firstCn = listCutiNormatif.first;
      setState(() {
        idCutiNormatifTerpilih = firstCn.id!;
        jatahCutiNormatifTerpilih = firstCn.jumlahCuti!;
      });

      setState(() {
        loadingGetCutiNormatif = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _onSubmitSikBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    //*Validasi Cuti Tahunan
    if (kategoriCutiTerpilih == "Cuti Tahunan") {
      //* Bila Jatah Cuti Karyawan = 0
      if (jatahCutiKaryawan == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Warning",
              msg: "Jatah Cuti Anda Sudah Habis",
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
      //* Bila Jumlah Hari Cuti > Jatah cuti Karyawan
      else if (jumlahHariCuti > jatahCutiKaryawan) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Warning",
              msg: "Jumlah Hari Melebihi Jatah Cuti Anda",
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
    }
    //* Validasi Cuti Normatif
    else if (kategoriCutiTerpilih == "Cuti Normatif") {
      if (jumlahHariCuti > jatahCutiNormatifTerpilih) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Warning",
              msg: "Jumlah Hari Melebihi Jatah Cuti Normatif",
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
    }

    //*Validasi Form
    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    //*Reformat Mulai Tanggal & Sampai Tanggal
    DateTimeRange? range = _formKey.currentState?.fields['range-cuti']!.value;

    if (range != null) {
      String mulaiTgl = DateFormat('dd-MM-yyyy').format(range.start);
      String sampaiTgl = DateFormat('dd-MM-yyyy').format(range.end);

      var header = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      };

      Map<String, String> body = {};

      if (kategoriCutiTerpilih == "Cuti Tahunan") {
        body = {
          'id_karyawan': widget.currUser.id.toString(),
          'nip': widget.currUser.nip.toString(),
          'keperluan': "Cuti",
          'kategori_cuti': "Cuti Tahunan",
          'sisa_cuti': jatahCutiKaryawan.toString(),
          'mulai_tanggal': mulaiTgl,
          'sampai_tanggal': sampaiTgl,
          'keterangan': _formKey.currentState!.fields['keterangan-cuti']?.value,
          'bisnis_id': widget.currUser.bisnisId.toString(),
          'area_kerja_id': widget.currUser.areaKerjaId.toString(),
          'id_department': widget.currUser.departemen.toString(),
          'disetujui': "0",
          'status': widget.currUser.level == 1 ? "1" : "0",
        };
      } else {
        body = {
          'id_karyawan': widget.currUser.id.toString(),
          'nip': widget.currUser.nip.toString(),
          'keperluan': "Cuti",
          'kategori_cuti': "Cuti Normatif",
          'cuti_normatif': idCutiNormatifTerpilih.toString(),
          'sisa_cuti': jatahCutiKaryawan.toString(),
          'mulai_tanggal': mulaiTgl,
          'sampai_tanggal': sampaiTgl,
          'keterangan': _formKey.currentState!.fields['keterangan-cuti']?.value,
          'bisnis_id': widget.currUser.bisnisId.toString(),
          'area_kerja_id': widget.currUser.areaKerjaId.toString(),
          'id_department': widget.currUser.departemen.toString(),
          'disetujui': "0",
          'status': widget.currUser.level == 1 ? "1" : "0",
        };
      }

      try {
        var request = http.MultipartRequest('POST',
            Uri.parse('$API_URL/v3/Sitc/updateSitc/${widget.sik.idSitc}'))
          ..fields.addAll(body)
          ..headers.addAll(header);
        var response = await request.send();
        if (response.statusCode == 201) {
          Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: CustomSnackbarContent(
                title: "Success",
                msg: "Edit SIK Cuti Berhasil",
                contentType: ContentType.success,
              ),
            ),
          );
          Navigator.of(context).pop(true);
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ListSikCutiKaryawanScreen(
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
                msg: "Edit SIK Cuti Gagal",
                contentType: ContentType.warning,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error $e');
      }
    } else {}
  }

  @override
  void initState() {
    _getCutiNormatifList();
    super.initState();
    kategoriCutiTerpilih = widget.sik.jenisCuti ?? '';
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.parse(widget.sik.tanggalMulai!);
    DateTime endDate = DateTime.parse(widget.sik.tanggalSelesai!);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Kamu yakin ingin kembali?',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Kalau kembali data yang sudah',
                    style: TextStyle(
                      color: Color(0xFF585858),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "kamu isi akan hilang",
                    style: TextStyle(
                      color: Color(0xFF585858),
                      fontSize: 14.sp,
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
                      width: 120.w,
                      height: 40.h,
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
                          'Tidak',
                          style: TextStyle(
                            color: Color(0xFF142638),
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
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ListSikCutiKaryawanScreen(
                                currUser: widget.currUser,
                              ),
                            ),
                          );
                        },
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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 80,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Column(
                  children: [
                    Text(
                      "Pengajuan Cuti",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              loadingGetCutiNormatif
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: GestureDetector(
                        onTap: () {
                          //FocusScope.of(context).requestFocus(FocusNode());
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: FormBuilder(
                            key: _formKey,
                            initialValue: {
                              'cuti-normatif': cutiNormatifTerpilih,
                              'keterangan-cuti': widget.sik.keterangan,
                              'range-cuti':
                                  DateTimeRange(start: startDate, end: endDate),
                              'pembuat': widget.currUser.namaKaryawan,
                              "jumlah-cuti": jatahCutiKaryawan.toString(),
                              "jenis-cuti": widget.sik.jenisCuti,
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomDropdownAndHeader(
                                  header: "Jenis Cuti",
                                  dropdownName: "jenis-cuti",
                                  items: listKategoriCuti,
                                  onChanged: (p0) {
                                    setState(() {
                                      kategoriCutiTerpilih = p0 as String;
                                    });
                                  },
                                ),
                                if (kategoriCutiTerpilih == "Cuti Tahunan") ...[
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "* sisa cuti tahunan : ${jatahCutiKaryawan.toString()}",
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFFDC3545),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  ),
                                ],
                                if (kategoriCutiTerpilih == "Cuti Tahunan") ...[
                                  const CustomTextFieldAndHeader(
                                    header: "Nama Karyawan",
                                    txtFieldName: "pembuat",
                                    keyboardType: TextInputType.name,
                                    isEnabled: false,
                                  ),
                                ],
                                const SizedBox(
                                  height: 10,
                                ),
                                if (kategoriCutiTerpilih ==
                                    "Cuti Normatif") ...[
                                  CustomDropdownAndHeader(
                                    header: "Cuti Normatif",
                                    dropdownName: "cuti-normatif",
                                    items: listNameCutiNormatif,
                                    onChanged: (p0) {
                                      CutiNormatif cnSelected = listCutiNormatif
                                          .firstWhere((element) =>
                                              element.namaCuti == p0);
                                      setState(() {
                                        idCutiNormatifTerpilih = cnSelected.id!;
                                        jatahCutiNormatifTerpilih =
                                            cnSelected.jumlahCuti!;
                                      });
                                    },
                                  ),
                                ],
                                kategoriCutiTerpilih == "Cuti Normatif"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            bottom: 15.0),
                                        child: Text(
                                          "*Jumlah Cuti Normatif : $jatahCutiNormatifTerpilih",
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Color(0xFFDC3545),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )
                                    : Container(),
                                if (kategoriCutiTerpilih ==
                                    "Cuti Normatif") ...[
                                  const CustomTextFieldAndHeader(
                                    header: "Nama Pembuat",
                                    txtFieldName: "pembuat",
                                    keyboardType: TextInputType.name,
                                    isEnabled: false,
                                  ),
                                ],
                                CustomDateTimeRangeAndHeader(
                                  header: "Tanggal Mulai - Selesai Cuti",
                                  dateTimeName: "range-cuti",
                                  labelText: "Klik untuk memilih tanggal cuti",
                                  isRequired: true,
                                  onChanged: (p0) {
                                    final range = p0 as DateTimeRange;

                                    final DateMulaiTgl = range.start;
                                    final DateSampaiTgl = range.end;

                                    setState(() {
                                      jumlahHariCuti =
                                          DateSampaiTgl.difference(DateMulaiTgl)
                                                  .inDays +
                                              1;
                                    });
                                  },
                                ),
                                const CustomTextAreaCuti(
                                  header: "Keterangan",
                                  textAreaName: "keterangan-cuti",
                                  isRequired: true,
                                ),
                                const Text(
                                  "*Harap isi keterangan",
                                  style: TextStyle(
                                    color: Color(0xFFB31312),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
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
                        'Kamu sudah yakin ingin mengirim',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Text(
                        'cuti ini ?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Kalau sudah kirim, kamu masih bisa ubah',
                        style: TextStyle(
                          color: const Color(0xFF585858),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "selagi belum di setujui oleh manajer",
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
                            onPressed: () {
                              _onSubmitSikBtnPress();
                            },
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
              'Kirim',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

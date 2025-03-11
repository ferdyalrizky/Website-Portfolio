import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/ganti_hari.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/list_absen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:intl/intl.dart';

import '../../../../../../../theme/colors/light_colors.dart';
import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';
import 'package:http/http.dart' as http;

class EditAbsenGantiHari extends StatefulWidget {
  final GantiHari gantihari;
  final Karyawan currUser;
  const EditAbsenGantiHari({
    super.key,
    required this.gantihari,
    required this.currUser,
  });

  @override
  State<EditAbsenGantiHari> createState() => _EditAbsenGantiHariState();
}

class _EditAbsenGantiHariState extends State<EditAbsenGantiHari> {
  final _formKey = GlobalKey<FormBuilderState>();

  DateTime tglMasuk = DateTime.now();
  DateTime tglGanti = DateTime.now();
  TimeOfDay jamKeluarKantor = const TimeOfDay(hour: 12, minute: 00);
  TimeOfDay jamMasukKantor = const TimeOfDay(hour: 12, minute: 00);

  // End Lampiran transportasi

  _onEditGantiHariBtnPress() async {
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

    Map<String, String> body = {};
    body = {
      'id_karyawan': widget.currUser.id.toString(),
      'nip': widget.currUser.nip.toString(),
      'keterangan': _formKey.currentState?.fields['keterangan']?.value,
      'disetujui': "0",
      'status': widget.currUser.level == 3 ? "1" : "0",
      'bisnis_id': widget.currUser.bisnisId.toString(),
      'area_kerja_id': widget.currUser.areaKerjaId.toString(),
      'id_department': widget.currUser.departemen!,
    };

    body.addAll({
      'tanggal_masuk': DateFormat('yyyy-MM-dd').format(tglMasuk),
    });

    body.addAll({
      'tanggal_ganti_hari': DateFormat('yyyy-MM-dd').format(tglGanti),
    });

    print(body);
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse('$API_URL/v2/gantiHari/update/${widget.gantihari.idHari}'))
        ..headers.addAll(header)
        ..fields.addAll(body);

      var response = await request.send();
      var streamedResponse = await http.Response.fromStream(response);
      print(streamedResponse.body);
      if (response.statusCode == 201) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Buat Ganti Hari Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListAbsen(
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
              msg: "Buat Ganti Hari Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error $e');
    }
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    ).then((value) {
      setState(() {
        tglMasuk = value!;
      });
    });
  }

  void _showDatePicker1() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    ).then((value) {
      setState(() {
        tglGanti = value!;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.gantihari.tglMasuk != null) {
      tglMasuk = DateTime.parse(
          widget.gantihari.tglMasuk!); // Ensure tglIzin is not null
    } else {
      tglMasuk = DateTime.now(); // Fallback to now if tglIzin is null
    }
    if (widget.gantihari.tglGanti != null) {
      tglGanti = DateTime.parse(
          widget.gantihari.tglGanti!); // Ensure tglIzin is not null
    } else {
      tglGanti = DateTime.now(); // Fallback to now if tglIzin is null
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 16),
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
                      fontSize: 14,
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
                          'Cek dulu deh',
                          style: TextStyle(
                            color: Color(0xFF142638),
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
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
                              builder: (context) => ListAbsen(
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
          child: GestureDetector(
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'pembuat': widget.currUser.namaKaryawan,
                'keterangan': widget.gantihari.keterangan,
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Ganti Hari",
                      style: TextStyle(
                        color: Color(0xFF121212),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text("Tanggal masuk kerja *",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity.w,
                      height: 58.h,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDatePicker();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          side: const BorderSide(
                              color: Color(0xFF1A1A1A), width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd-MM-yyyy').format(tglMasuk),
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 16),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF000000),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text("Tanggal ganti hari",
                        style: TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity.w,
                      height: 58.h,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDatePicker1();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          side: const BorderSide(
                              color: Color(0xFF1A1A1A), width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd-MM-yyyy').format(tglGanti),
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 16),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF000000),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const CustomTextAreaAndHeader(
                      header: "Alasan *",
                      textAreaName: "keterangan",
                      labelText: "Ketik alasanmu...",
                      isRequired: true,
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
                        'Kamu yakin mengubah ganti hari?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Data akan dikirim ke manajer kamu.',
                        style: TextStyle(
                          color: const Color(0xFF585858),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "Jika disetujui, tidak bisa diubah",
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
                              _onEditGantiHariBtnPress();
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

import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/list_izin.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import '../../../../../theme/colors/text_style.dart';
import '../../../../../utils/constant.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../components/custom_datetime_picker_and_header.dart';
import '../components/custom_dropdown_and_header.dart';
import '../components/custom_text_area_and_header.dart';
import '../components/custom_text_field_and_header.dart';

import 'package:http/http.dart' as http;

class FormIzinScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormIzinScreen({super.key, required this.currUser});

  @override
  State<FormIzinScreen> createState() => _FormIzinScreenState();
}

class _FormIzinScreenState extends State<FormIzinScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String keperluanTerpilih = "Datang Telat";
  List<String> listKeperluanIzin = [
    "Datang Telat",
    "Pulang Cepat",
    "Izin Sementara"
  ];

  File? lampiranTelat;

  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;

  bool hidebutton1 = true;
  bool hideprogress1 = true;
  bool isVisible1 = false;

  DateTime tglKeluarKantor = DateTime.now();
  TimeOfDay jamKeluarKantor = const TimeOfDay(hour: 12, minute: 00);
  TimeOfDay jamMasukKantor = const TimeOfDay(hour: 12, minute: 00);

  // Visibility
  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "tag") {
        visibilityTag = visibility;
      }
    });
  }

  //Open getlampiran telat

  Future<void> getLampiranTelat() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranTelat = File(imagePicked.path);
      setState(() {
        isVisible1 = false;
        hidebutton1 = false;
        progress = 0;
      });
      // simulate image upload progress
      for (int i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 50));
        setState(() {
          progress = i / 100;
        });
      }
      setState(() {
        imageLoaded = true;
        hideprogress1 = false;
        isVisible1 = true;
      });
    }
  }

  // Open getlampiran sementara

  _onSubmitIzinBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    if (keperluanTerpilih == "Datang Telat" && lampiranTelat == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Kamu telat kenapa? foto dulu dong..."
                : "Harus lampirkan foto alasan telat",
            contentType: ContentType.failure,
          ),
        ),
      );

      return;
    }

    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    final dateTimeSplit = _formKey
        .currentState?.fields['tanggal-jam-izin']?.value
        .toString()
        .split(" ");

    Map<String, String> body = {};
    body = {
      'id_karyawan': widget.currUser.id.toString(),
      'nip': widget.currUser.nip.toString(),
      'keperluan': keperluanTerpilih,
      'keterangan': _formKey.currentState?.fields['keterangan']?.value,
      'bisnis_id': widget.currUser.bisnisId.toString(),
      'area_kerja_id': widget.currUser.areaKerjaId.toString(),
      'disetujuhi': "0",
      'status': widget.currUser.level == 1 ? "1" : "0",
      'id_department': widget.currUser.departemen!,
    };

    if (keperluanTerpilih == "Datang Telat") {
      body.addAll({
        "jam_datang_telat": DateFormat('kk:mm')
            .format(_formKey.currentState?.fields['tanggal-jam-izin']?.value!),
        'tanggal_izin': dateTimeSplit![0].toString(),
      });
    } else if (keperluanTerpilih == "Pulang Cepat") {
      body.addAll({
        "jam_pulang_cepat": DateFormat('kk:mm')
            .format(_formKey.currentState?.fields['tanggal-jam-izin']?.value!),
        'tanggal_izin': dateTimeSplit![0].toString(),
      });
    } else if (keperluanTerpilih == "Izin Sementara") {
      body.addAll({
        'tanggal_izin': DateFormat('yyyy-MM-dd').format(tglKeluarKantor),
        "jam_keluar":
            "${jamKeluarKantor.hour.toString().padLeft(2, '0')}:${jamKeluarKantor.minute.toString().padLeft(2, '0')}",
        "jam_masuk":
            "${jamMasukKantor.hour.toString().padLeft(2, '0')}:${jamMasukKantor.minute.toString().padLeft(2, '0')}",
      });
    }

    print(body);
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$API_URL/v3/buatDtpc'))
            ..headers.addAll(header)
            ..fields.addAll(body);

      if (keperluanTerpilih == "Datang Telat") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'lampiran_telat', lampiranTelat!.path),
        );
      }

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
              msg: "Buat Izin Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListIzin(
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
              msg: "Buat Izin Gagal",
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
        tglKeluarKantor = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 80.h,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'pembuat': widget.currUser.namaKaryawan,
                'keperluan': "Datang Telat",
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  const Text(
                    "Pengajuan Izin",
                    style: TextStyle(
                      color: Color(0xFF121212),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  const CustomTextFieldAndHeader(
                    header: "Nama Karyawan",
                    txtFieldName: "pembuat",
                    keyboardType: TextInputType.name,
                    isEnabled: false,
                  ),
                  CustomDropdownAndHeader(
                    header: "Jenis Izin",
                    dropdownName: "keperluan",
                    items: listKeperluanIzin,
                    onChanged: (p0) {
                      setState(() {
                        keperluanTerpilih = p0 as String;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  keperluanTerpilih == "Datang Telat" ||
                          keperluanTerpilih == "Pulang Cepat"
                      ? CustomDateTimePickerAndHeader(
                          header: keperluanTerpilih == "Datang Telat"
                              ? "Tanggal & Jam Datang Telat"
                              : "Tanggal & Jam Pulang Cepat",
                          dateTimeName: "tanggal-jam-izin",
                          labelText: keperluanTerpilih == "Datang Telat"
                              ? DateFormat('y/M/d - H:m:s')
                                  .format(DateTime.now())
                              : "Klik untuk memilih tanggal dan jam pulang cepat",
                          isRequired: true,
                        )
                      //Izin Sementara
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                left: 3.0,
                              ).r,
                              child: Text("Tanggal Keluar Kantor",
                                  style: TextStyle(
                                    color: const Color(0xFF000000),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                      left: 3.0, right: 2.0, bottom: 10)
                                  .r,
                              width: double.infinity,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd-MM-yyyy')
                                          .format(tglKeluarKantor),
                                      style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16.sp),
                                    ),
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF000000),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 3.0,
                                      ).r,
                                      child: RichText(
                                        text: TextSpan(
                                          style: CustomTextStyle.bodySmall,
                                          children: [
                                            TextSpan(
                                                text: "Jam Keluar Kantor",
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 3.0,
                                        right: 15.0,
                                        bottom: 10,
                                      ).r,
                                      width: 170.w,
                                      height: 58.h,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          TimeOfDay? newTime =
                                              await showTimePicker(
                                                  context: context,
                                                  initialTime: jamKeluarKantor);
                                          if (newTime == null) return;
                                          setState(() {
                                            jamKeluarKantor = newTime;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          side: const BorderSide(
                                              color: Color(0xFF1A1A1A),
                                              width: 1.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${jamKeluarKantor.hour.toString().padLeft(2, '0')}:${jamKeluarKantor.minute.toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.access_time,
                                              color: Color(0xFF000000),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: CustomTextStyle.bodySmall,
                                        children: [
                                          TextSpan(
                                            text: "Jam Kembali Ke Kantor",
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                              left: 3.0,
                                              right: 10.0,
                                              bottom: 10)
                                          .r,
                                      width: 170.w,
                                      height: 58.h,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          TimeOfDay? newTime =
                                              await showTimePicker(
                                                  context: context,
                                                  initialTime: jamMasukKantor);
                                          if (newTime == null) return;
                                          setState(() {
                                            jamMasukKantor = newTime;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          side: const BorderSide(
                                              color: Color(0xFF1A1A1A),
                                              width: 1.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${jamMasukKantor.hour.toString().padLeft(2, '0')}:${jamMasukKantor.minute.toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                  color: Colors.grey[800],
                                                  fontSize: 16.sp),
                                            ),
                                            const Icon(
                                              Icons.access_time,
                                              color: Color(0xFF000000),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                left: 3.0,
                              ).r,
                              child: const Column(
                                children: [
                                  Text(
                                    "*Maksimal izin hanya 3 jam",
                                    style: TextStyle(color: Color(0xFFB31312)),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  const CustomTextAreaAndHeader(
                    header: "Keterangan",
                    textAreaName: "keterangan",
                    labelText: "Tulis Keterangan/Alasan anda izin",
                    isRequired: true,
                  ),
                  keperluanTerpilih == "Datang Telat"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah bukti Datang telat*",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: hidebutton1,
                              child: DottedBorder(
                                color: Colors.grey,
                                strokeWidth: 2,
                                dashPattern: const [15, 8],
                                strokeCap: StrokeCap.round,
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                padding: const EdgeInsets.all(8),
                                child: InkWell(
                                  child: SizedBox(
                                    height: 100,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      onPressed: () async {
                                        getLampiranTelat();
                                      },
                                      child: const Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "Maksimum unggah 10 Mb",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            lampiranTelat != null
                                ? Visibility(
                                    visible: hideprogress1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: LightColors.kFagettiBlue,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: LightColors.kFagettiBlue,
                                            offset: Offset(4, 4),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.folder_rounded,
                                                size: 32,
                                                color: LightColors.kFagettiBlue,
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 20),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text(
                                                            "Unggah File Datang Telat",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                visibilityTag =
                                                                    !visibilityTag;
                                                                _changed(
                                                                    visibilityTag,
                                                                    "tag");
                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            50)); // Add delay here
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            16.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <Widget>[
                                                                    Text(
                                                                      "${(progress * 101).toStringAsFixed(0)} %",
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodySmall,
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              8.0),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            child: SizedBox(
                                                              height: 8,
                                                              child:
                                                                  LinearProgressIndicator(
                                                                color: const Color(
                                                                    0xFFFFCA2B),
                                                                value: progress,
                                                                backgroundColor:
                                                                    const Color(
                                                                        0xFFFFEFBD),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            Visibility(
                              visible: isVisible1,
                              child: InstaImageViewer(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.file_copy_outlined,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      "File unggahan untuk datang telat",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        showGeneralDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            barrierLabel:
                                                MaterialLocalizations.of(
                                                        context)
                                                    .modalBarrierDismissLabel,
                                            barrierColor: Colors.black87,
                                            transitionDuration:
                                                const Duration(milliseconds: 0),
                                            pageBuilder: (BuildContext
                                                    buildContext,
                                                Animation animation,
                                                Animation secondaryAnimation) {
                                              return Center(
                                                child: Container(
                                                  height: 300,
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Opacity(
                                                    opacity:
                                                        imageLoaded ? 1 : 0,
                                                    child: Image.file(
                                                      lampiranTelat!,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      child: const Text(
                                        'Lihat',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          hideprogress1 =
                                              true; // Set to false first
                                        });
                                        await getLampiranTelat(); // Wait for getSuratDokter to complete
                                        setState(() {
                                          hideprogress1 =
                                              false; // Set to true after completion
                                        });
                                      },
                                      child: const Text(
                                        'Ubah',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 5,
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
                      'SIK ini ?',
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
                            _onSubmitIzinBtnPress();
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
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

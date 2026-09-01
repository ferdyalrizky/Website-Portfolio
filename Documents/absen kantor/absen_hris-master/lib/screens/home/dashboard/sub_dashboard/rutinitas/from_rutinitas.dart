import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
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

class FormRutinitasScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormRutinitasScreen({super.key, required this.currUser});

  @override
  State<FormRutinitasScreen> createState() => _FormRutinitasScreenState();
}

class _FormRutinitasScreenState extends State<FormRutinitasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String keperluanTerpilih = "Datang Telat";
  List<String> listKeperluanIzin = [
    "Datang Telat",
    "Pulang Cepat",
    "Izin Sementara"
  ];

  File? lampiranSementara;
  File? lampiranTelat;
  File? lampiranCepat;
  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;

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

  //Open Camera Telat
  Future<void> getLampiranTelat() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranTelat = File(imagePicked.path);
      setState(() {
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
      });
    }
  }

  // Open Camera Sementara
  Future<void> getLampiranSementara() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranSementara = File(imagePicked.path);
      setState(() {
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
      });
    }
  }

  Future<void> getLampiranCepat() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranCepat = File(imagePicked.path);
      setState(() {
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
      });
    }
  }

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
      if (keperluanTerpilih == "Pulang Cepat") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'lampiran_pulang_cepat', lampiranCepat!.path),
        );
      }
      if (keperluanTerpilih == "Izin Sementara") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'lampiran_izin_sementara', lampiranSementara!.path),
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
        Navigator.pop(context);
      } else {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(
          //   content: Text(
          //     "Buat Surat SIK Sakit Gagal. Hubungi Tim IT",
          //     style: const TextStyle(fontSize: 16),
          //   ),
          // ),
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
        toolbarHeight: 80,
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
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Aktifitas",
                    style: TextStyle(
                      color: Color(0xFF121212),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CustomTextFieldAndHeader(
                    header: "Nama Karyawan",
                    txtFieldName: "pembuat",
                    keyboardType: TextInputType.name,
                    isEnabled: false,
                  ),
                  CustomDropdownAndHeader(
                    header: "Jenis Pertemuan",
                    dropdownName: "keperluan",
                    items: listKeperluanIzin,
                    onChanged: (p0) {
                      setState(() {
                        keperluanTerpilih = p0 as String;
                      });
                    },
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
                              ),
                              child: const Text("Tanggal Keluar Kantor",
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 3.0, right: 10.0, bottom: 20),
                              width: 500,
                              height: 58,
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
                                          fontSize: 16),
                                    ),
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF000000),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 3.0,
                                      ),
                                      child: RichText(
                                        text: const TextSpan(
                                          style: CustomTextStyle.bodySmall,
                                          children: [
                                            TextSpan(
                                                text: "Jam Keluar Kantor",
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 3.0, right: 10.0, bottom: 20),
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
                                                  fontSize: 16),
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
                                      text: const TextSpan(
                                        style: CustomTextStyle.bodySmall,
                                        children: [
                                          TextSpan(
                                            text: "Jam Kembali Ke Kantor",
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 3.0, right: 10.0, bottom: 20),
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
                                                  fontSize: 16),
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
                              margin: const EdgeInsets.only(left: 3.0),
                              child: const Column(
                                children: [
                                  Text(
                                    "*Maksimal izin hanya 3 jam",
                                    style: TextStyle(color: Color(0xFFB31312)),
                                  )
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
                  keperluanTerpilih == "Pulang Cepat"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah file pertemuan*",
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
                            DottedBorder(
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      getLampiranCepat();
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
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            lampiranCepat != null
                                ? Container(
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
                                                          "Unggah File Pulang Cepat",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                                  Icon(
                                                                    visibilityTag
                                                                        ? Icons
                                                                            .visibility_off
                                                                        : Icons
                                                                            .visibility,
                                                                    color: visibilityTag
                                                                        ? Colors.grey[
                                                                            600]
                                                                        : Colors
                                                                            .grey[400],
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
                                                                  .circular(16),
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
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "${(progress * 101).toStringAsFixed(0)} %",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 24.0),
                                                  visibilityTag
                                                      ? InstaImageViewer(
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .file_copy_outlined,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              const Text(
                                                                "File unggahan untuk datang telat",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500));
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          true,
                                                                      barrierLabel:
                                                                          MaterialLocalizations.of(
                                                                                  context)
                                                                              .modalBarrierDismissLabel,
                                                                      barrierColor:
                                                                          Colors
                                                                              .black87,
                                                                      transitionDuration:
                                                                          const Duration(
                                                                              milliseconds:
                                                                                  20),
                                                                      pageBuilder: (BuildContext
                                                                              buildContext,
                                                                          Animation
                                                                              animation,
                                                                          Animation
                                                                              secondaryAnimation) {
                                                                        return LayoutBuilder(
                                                                          builder:
                                                                              (context, constraints) {
                                                                            return Center(
                                                                              child: Opacity(
                                                                                opacity: imageLoaded ? 1 : 0,
                                                                                child: Image.file(
                                                                                  lampiranCepat!,
                                                                                  fit: BoxFit.contain,
                                                                                  width: constraints.maxWidth, // Set the width to the available width
                                                                                  height: constraints.maxHeight, // Set the height to the available height
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      });
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Lihat',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 15,
                  ),
                  keperluanTerpilih == "Datang Telat"
                      // ? const CustomImagePickerAndHeader(
                      //     header: "File Lampiran Datang Telat",
                      //     imagePickerName: "lampiran-telat",
                      //     isRequired: true,
                      //   )
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah Pertemuan*",
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
                            DottedBorder(
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
                                        borderRadius: BorderRadius.circular(8),
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
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            lampiranTelat != null
                                ? Container(
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
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                                  Icon(
                                                                    visibilityTag
                                                                        ? Icons
                                                                            .visibility_off
                                                                        : Icons
                                                                            .visibility,
                                                                    color: visibilityTag
                                                                        ? Colors.grey[
                                                                            600]
                                                                        : Colors
                                                                            .grey[400],
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
                                                                  .circular(16),
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
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "${(progress * 101).toStringAsFixed(0)} %",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 24.0),
                                                  visibilityTag
                                                      ? InstaImageViewer(
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .file_copy_outlined,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              const Text(
                                                                "File unggahan untuk datang telat",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500));
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          true,
                                                                      barrierLabel:
                                                                          MaterialLocalizations.of(
                                                                                  context)
                                                                              .modalBarrierDismissLabel,
                                                                      barrierColor:
                                                                          Colors
                                                                              .black87,
                                                                      transitionDuration:
                                                                          const Duration(
                                                                              milliseconds:
                                                                                  20),
                                                                      pageBuilder: (BuildContext
                                                                              buildContext,
                                                                          Animation
                                                                              animation,
                                                                          Animation
                                                                              secondaryAnimation) {
                                                                        return Center(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                300,
                                                                            width:
                                                                                300,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Opacity(
                                                                              opacity: imageLoaded ? 1 : 0,
                                                                              child: Image.file(
                                                                                lampiranTelat!,
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Lihat',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 15,
                  ),
                  keperluanTerpilih == "Izin Sementara"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Aktifitas*",
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
                            DottedBorder(
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      getLampiranSementara();
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
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            lampiranSementara != null
                                ? Container(
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
                                                          "Unggah File Izin Sementara",
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                                  Icon(
                                                                    visibilityTag
                                                                        ? Icons
                                                                            .visibility_off
                                                                        : Icons
                                                                            .visibility,
                                                                    color: visibilityTag
                                                                        ? Colors.grey[
                                                                            600]
                                                                        : Colors
                                                                            .grey[400],
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
                                                                  .circular(16),
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
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "${(progress * 101).toStringAsFixed(0)} %",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 24.0),
                                                  visibilityTag
                                                      ? InstaImageViewer(
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .file_copy_outlined,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              const Text(
                                                                "File unggahan untuk izin sementara",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500));
                                                                  showGeneralDialog(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          true,
                                                                      barrierLabel:
                                                                          MaterialLocalizations.of(
                                                                                  context)
                                                                              .modalBarrierDismissLabel,
                                                                      barrierColor:
                                                                          Colors
                                                                              .black87,
                                                                      transitionDuration:
                                                                          const Duration(
                                                                              milliseconds:
                                                                                  20),
                                                                      pageBuilder: (BuildContext
                                                                              buildContext,
                                                                          Animation
                                                                              animation,
                                                                          Animation
                                                                              secondaryAnimation) {
                                                                        return Center(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                300,
                                                                            width:
                                                                                300,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Opacity(
                                                                              opacity: imageLoaded ? 1 : 0,
                                                                              child: Image.file(
                                                                                lampiranSementara!,
                                                                                fit: BoxFit.fill,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      });
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Lihat',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        )
                      : Container(),
                  const SizedBox(
                    height: 15,
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
          onPressed: () {
            _onSubmitIzinBtnPress();
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

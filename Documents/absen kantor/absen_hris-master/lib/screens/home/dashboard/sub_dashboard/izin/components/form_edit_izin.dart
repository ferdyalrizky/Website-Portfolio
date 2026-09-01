import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/izin.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime_picker_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/izin/list_izin.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/theme/colors/text_style.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class EditFormIzin extends StatefulWidget {
  final Izin izin;
  final Karyawan currUser;
  final String? existingLampiranTelat;

  const EditFormIzin({
    super.key,
    required this.izin,
    required this.currUser,
    this.existingLampiranTelat,
  });

  @override
  State<EditFormIzin> createState() => _EditFormIzinState();
}

class _EditFormIzinState extends State<EditFormIzin> {
  final _formKey = GlobalKey<FormBuilderState>();
  late bool isEditing;
  String keperluanTerpilih = "";
  List<String> listKeperluanIzin = [
    "Datang Telat",
    "Pulang Cepat",
    "Izin Sementara"
  ];

  File? lampiranTelat;
  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;
  bool hidebutton = true;
  bool hideprogress = true;
  bool isVisible = true;

  bool hidebutton1 = true;
  bool hideprogress1 = true;
  bool isVisible1 = true;

  bool hidebutton2 = true;
  bool hideprogress2 = true;
  bool isVisible2 = true;

  bool isNewImageSelected = false;
  bool isNewImageSelected1 = false;
  bool isNewImageSelected2 = false;

  late DateTime tglKeluarKantor;
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
        lampiranTelat = File(imagePicked.path);
        isNewImageSelected = true;
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

  _onEditIzinBtnPress() async {
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
        "tanggal_izin": DateFormat('yyyy-MM-dd').format(tglKeluarKantor),
        "jam_keluar":
            "${jamKeluarKantor.hour.toString().padLeft(2, '0')}:${jamKeluarKantor.minute.toString().padLeft(2, '0')}",
        "jam_masuk":
            "${jamMasukKantor.hour.toString().padLeft(2, '0')}:${jamMasukKantor.minute.toString().padLeft(2, '0')}",
      });
    }
    print("Tanggal Izin: ${body['tanggal_izin']}");
    print("Jam Izin: ${body['jam']}");

    print(body);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/v3/dtpc/update/${widget.izin.idIzin}'))
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
              msg: "Edit Izin Berhasil",
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
              msg: "Edit Izin Gagal",
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

  void _showTimePicker() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: jamKeluarKantor,
    );
    if (newTime == null) return;
    setState(() {
      jamKeluarKantor = newTime; // Update the time
    });
  }

  void _showTimePicker1() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: jamMasukKantor,
    );
    if (newTime == null) return;
    setState(() {
      jamMasukKantor = newTime; // Update the time
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.izin.tglIzin != null) {
      tglKeluarKantor =
          DateTime.parse(widget.izin.tglIzin!); // Ensure tglIzin is not null
    } else {
      tglKeluarKantor = DateTime.now(); // Fallback to now if tglIzin is null
    }
    if (widget.izin.jamKeluar != null) {
      // Assuming jamKeluar is stored as a string in "HH:mm" format
      final timeParts = widget.izin.jamKeluar!.split(':');
      jamKeluarKantor = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      jamKeluarKantor = TimeOfDay.now(); // Fallback to current time
    }
    if (widget.izin.jamMasuk != null) {
      // Assuming jamKeluar is stored as a string in "HH:mm" format
      final timeParts = widget.izin.jamMasuk!.split(':');
      jamMasukKantor = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      jamMasukKantor = TimeOfDay.now(); // Fallback to current time
    }

    keperluanTerpilih = widget.izin.keperluan ?? '';
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
                              builder: (context) => ListIzin(
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
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: FormBuilder(
                key: _formKey,
                initialValue: {
                  'pembuat': widget.currUser.namaKaryawan,
                  'keperluan': widget.izin.keperluan,
                  'keterangan': widget.izin.keterangan,
                  'tanggal-jam-izin': _getLatestDateTime() ?? DateTime.now(),
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Edit Izin",
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
                      header: "Jenis Izin",
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
                                ? (widget.izin.tglIzin != null &&
                                        widget.izin.dtgTelat != null)
                                    ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.izin.tglIzin!))} - ${DateFormat('kk:mm').format(DateTime.parse(widget.izin.dtgTelat!))}"
                                    : "Tanggal dan Jam Tidak Tersedia"
                                : (widget.izin.tglIzin != null &&
                                        widget.izin.pulangCpt != null)
                                    ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.izin.tglIzin!))} - ${DateFormat('kk:mm').format(DateTime.parse(widget.izin.pulangCpt!))}"
                                    : (widget.izin.tglIzin != null)
                                        ? "${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.izin.tglIzin!))} - ${DateFormat('kk:mm').format(DateTime.now())}"
                                        : "Tanggal dan Jam Tidak Tersedia",
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
                                  onPressed: _showDatePicker,
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
                                        DateFormat('dd-MM-yyyy').format(
                                            tglKeluarKantor), // Display the selected date
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          onPressed: _showTimePicker,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          onPressed: _showTimePicker1,
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
                                      style:
                                          TextStyle(color: Color(0xFFB31312)),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25.0),
                            ],
                          ),
                    const CustomTextAreaAndHeader(
                      header: "Keterangan",
                      textAreaName: "keterangan",
                      labelText: "Tulis Keterangan/Alasan anda izin",
                      isRequired: true,
                    ),
                    const SizedBox(
                      height: 5,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                  color:
                                                      LightColors.kFagettiBlue,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                              "Unggah File Datang Telat",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                child:
                                                                    Container(
                                                                  margin: const EdgeInsets
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
                                                                        style: Theme.of(context)
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
                                                                  value:
                                                                      progress,
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
                                        await Future.delayed(
                                            const Duration(milliseconds: 500));
                                        showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel:
                                              MaterialLocalizations.of(context)
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
                                                decoration: const BoxDecoration(
                                                    color: Colors.transparent),
                                                child: Opacity(
                                                  opacity:
                                                      1, // Always show the image
                                                  child: isNewImageSelected
                                                      ? Image.file(
                                                          lampiranTelat!,
                                                          fit: BoxFit
                                                              .contain) // Show the new image
                                                      : CachedNetworkImage(
                                                          imageUrl:
                                                              '$API_URL_IMAGE/${widget.izin.lampiranPath}', // Show the existing image
                                                          fit: BoxFit.contain,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const CircularProgressIndicator(),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
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
                              )
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 5,
                    ),
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
                              _onEditIzinBtnPress();
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

  DateTime? _getLatestDateTime() {
    // Create a list of date strings
    List<String?> dateStrings = [
      widget.izin.tglIzin,
      widget.izin.dtgTelat,
      widget.izin.pulangCpt,
    ];

    // Filter out null values and parse the date strings
    List<DateTime> dateTimes = dateStrings
        .where((dateString) => dateString != null)
        .map((dateString) => DateTime.parse(dateString!))
        .toList();

    // Get the latest date
    DateTime? latestDate = dateTimes.isNotEmpty
        ? dateTimes.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    return latestDate;
  }
}

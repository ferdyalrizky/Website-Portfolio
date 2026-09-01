import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/sik.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/list_sik_sakit_karyawan_screen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_datetime.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/list_biaya.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../models/karyawan.dart';
import '../../../../../../../theme/colors/light_colors.dart';
import '../../../../../../../theme/colors/text_style.dart';
import '../../../../../../../utils/constant.dart';
import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';
import '../../../components/custom_datetime_range_and_header.dart';
import '../../../components/custom_text_area_and_header.dart';
import '../../../components/custom_text_field_and_header.dart';

class FormEdit extends StatefulWidget {
  final Sik sik;
  final Karyawan currUser;
  const FormEdit({
    super.key,
    required this.sik,
    required this.currUser,
  });

  @override
  State<FormEdit> createState() => _FormEditState();
}

class _FormEditState extends State<FormEdit> {
  File? lampiranSuratDokter;
  File? watermarkedlampiranSuratDokter;
  Uint8List? lampiranSuratDokterByte;
  Uint8List? watermarkedlampiranSuratDokterByte;
  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;
  bool hidebutton = true;
  bool hideprogress = true;
  bool isVisible = true;

  bool isNewImageSelected = false;

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "tag") {
        visibilityTag = visibility;
      }
    });
  }

  Future getSuratDokter() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranSuratDokter = File(imagePicked.path);
      setState(() {
        lampiranSuratDokter =
            File(imagePicked.path); // Update the image variable
        isNewImageSelected = true; // Set the flag to true
        isVisible = false;
        hidebutton = false;
        progress = 0;
      });
      // simulate image upload progress
      for (int i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 25));
        setState(() {
          progress = i / 100;
        });
      }
      setState(() {
        imageLoaded = true;
        hideprogress = false;
        isVisible = true;
      });
    }
  }

  Future watermarkSuratDokter() async {
    String watermarkText = "";
    var t = await lampiranSuratDokter!.readAsBytes();
    lampiranSuratDokterByte = Uint8List.fromList(t);
    watermarkedlampiranSuratDokterByte = await ImageWatermark.addTextWatermark(
      imgBytes: lampiranSuratDokterByte!,
      watermarkText: watermarkText,
      dstX: 30,
      dstY: 30,
    );
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    watermarkedlampiranSuratDokter = await File("$tempPath/image.jpg")
        .writeAsBytes(watermarkedlampiranSuratDokterByte!);
  }

  _onSubmitSikBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    if (lampiranSuratDokter == null && !isNewImageSelected) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Foto surat dokternya dulu dong beb..."
                : "Harus lampirkan foto surat dokter",
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
    if (isNewImageSelected) {
      await watermarkSuratDokter();
    }

    DateTimeRange? range = _formKey.currentState?.fields['range-sakit']!.value;
    if (range != null) {
      String mulaiTgl = DateFormat('dd-MM-yyyy').format(range.start);
      String sampaiTgl = DateFormat('dd-MM-yyyy').format(range.end);

      var header = {
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      };

      Map<String, String> body = {
        'id_karyawan': widget.currUser.id.toString(),
        'nip': widget.currUser.nip.toString(),
        'keperluan': "Sakit",
        'mulai_tanggal': mulaiTgl,
        'sampai_tanggal': sampaiTgl,
        'keterangan': _formKey.currentState!.fields['keterangan-sakit']?.value,
        'bisnis_id': widget.currUser.bisnisId.toString(),
        'area_kerja_id': widget.currUser.areaKerjaId.toString(),
        'id_department': widget.currUser.departemen.toString(),
        'disetujui': "0",
        'status': "1",
      };

      try {
        var request = http.MultipartRequest('POST',
            Uri.parse('$API_URL/v3/Sitc/updateSitc/${widget.sik.idSitc}'))
          ..fields.addAll(body)
          ..headers.addAll(header);

        if (isNewImageSelected) {
          request.files.add(await http.MultipartFile.fromPath(
              'file_lampiran_sakit', watermarkedlampiranSuratDokter!.path));
        }

        var response = await request.send();
        print(response);

        if (response.statusCode == 201) {
          Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: CustomSnackbarContent(
                title: "Success",
                msg: "Buat SIK Sakit Berhasil",
                contentType: ContentType.success,
              ),
            ),
          );
          Navigator.of(context).pop(true);
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => ListSikSakitKaryawanScreen(
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
                msg: "Buat SIK Sakit Gagal",
                contentType: ContentType.failure,
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error $e');
      }
    } else {
      // Handle the case when range is null
    }
  }

  final _formKey = GlobalKey<FormBuilderState>();

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
                              builder: (context) => ListSikSakitKaryawanScreen(
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
                  'range-sakit': DateTimeRange(start: startDate, end: endDate),
                  'pembuat': widget.currUser.namaKaryawan,
                  'divisi-pembuat':
                      widget.currUser.divisiId ?? "Divisi not define",
                  "jenis-tidak-hadir": "Sakit",
                  "jumlah-cuti": widget.currUser.jatahCuti.toString(),
                  'keterangan-sakit': widget.sik.keterangan,
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Edit Sakit",
                      style: TextStyle(
                        color: Color(0xFF121212),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomTextFieldAndHeader(
                          header: "Nama Karyawan",
                          txtFieldName: "pembuat",
                          keyboardType: TextInputType.name,
                          isEnabled: false,
                        ),
                        const CustomDateTimeRangeAndHeader(
                          header: "Tanggal Mulai - Selesai Sakit",
                          dateTimeName: "range-sakit",
                          isRequired: true,
                        ),
                        const CustomTextAreaAndHeader(
                          header: "Keterangan",
                          textAreaName: "keterangan-sakit",
                          labelText: "Tulis Keterangan Sakit Anda",
                          isRequired: true,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah bukti sakit*",
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
                            const SizedBox(
                              height: 20,
                            ),
                            lampiranSuratDokter != null
                                ? Visibility(
                                    visible: hideprogress,
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
                                                            "Unggah File Sakit",
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
                              visible: isVisible,
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
                                    "File unggahan untuk sakit",
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
                                            MaterialLocalizations.of(context)
                                                .modalBarrierDismissLabel,
                                        barrierColor: Colors.black87,
                                        transitionDuration:
                                            const Duration(milliseconds: 0),
                                        pageBuilder: (BuildContext buildContext,
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
                                                        lampiranSuratDokter!,
                                                        fit: BoxFit
                                                            .contain) // Show the new image
                                                    : CachedNetworkImage(
                                                        imageUrl:
                                                            '$API_URL_IMAGE/${widget.sik.lampiranPath}', // Show the existing image
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
                                        hideprogress =
                                            true; // Set to false first
                                      });
                                      await getSuratDokter(); // Wait for getSuratDokter to complete
                                      setState(() {
                                        hideprogress =
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
                      ],
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
                        'Kamu yakin ingin edit pengajuan',
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
                        'sakit??',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Kalau sudah kirim, kamu masih bisa edit',
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
              'Edit',
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

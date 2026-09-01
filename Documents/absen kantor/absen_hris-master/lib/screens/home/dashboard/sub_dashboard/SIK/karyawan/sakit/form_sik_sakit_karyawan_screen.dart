import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/components/form_sakit.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/SIK/karyawan/sakit/list_sik_sakit_karyawan_screen.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/theme/colors/text_style.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../../../widgets/dialog.dart';
import '../../../components/custom_datetime_range_and_header.dart';
import '../../../components/custom_text_area_and_header.dart';
import '../../../components/custom_text_field_and_header.dart';

class FormSikSakitKaryawanScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormSikSakitKaryawanScreen({Key? key, required this.currUser})
      : super(key: key);

  @override
  State<FormSikSakitKaryawanScreen> createState() =>
      _FormSikSakitKaryawanScreenState();
}

class _FormSikSakitKaryawanScreenState
    extends State<FormSikSakitKaryawanScreen> {
  File? lampiranSuratDokter;
  Uint8List? lampiranSuratDokterByte;
  Uint8List? watermarkedlampiranSuratDokterByte;
  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;
  bool hidebutton = true;
  bool hideprogress = true;
  bool isVisible = false;

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
        isVisible = false;
        hidebutton = false;
        progress = 0;
      });
      // simulate image upload progress
      for (int i = 0; i < 100; i++) {
        await Future.delayed(Duration(milliseconds: 50));
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

  _onSubmitSikBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    if (lampiranSuratDokter == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Foto surat dokternya dulu..."
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
        'status': widget.currUser.level == 1 ? "1" : "0",
      };

      try {
        var request =
            http.MultipartRequest('POST', Uri.parse('$API_URL/v3/buatSitc'))
              ..fields.addAll(body)
              ..headers.addAll(header);

        request.files.add(await http.MultipartFile.fromPath(
            'file_lampiran_sakit', lampiranSuratDokter!.path));

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
                'divisi-pembuat':
                    widget.currUser.divisiId ?? "Divisi not define",
                "jenis-tidak-hadir": "Sakit",
                "jumlah-cuti": widget.currUser.jatahCuti.toString(),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Pengajuan Sakit",
                    style: TextStyle(
                      color: Color(0xFF121212),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
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
                            text: TextSpan(
                              style: CustomTextStyle.bodySmall,
                              children: [
                                const TextSpan(
                                    text: "Unggah bukti sakit*",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: hidebutton,
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      getSuratDokter();
                                    },
                                    child: Column(
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
                          ),
                          SizedBox(
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
                                                    margin: EdgeInsets.only(
                                                        right: 20),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Unggah File Sakit",
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
                                                              Future.delayed(Duration(
                                                                  milliseconds:
                                                                      50)); // Add delay here
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
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
                                                                  .circular(16),
                                                          child: SizedBox(
                                                            height: 8,
                                                            child:
                                                                LinearProgressIndicator(
                                                              color: Color(
                                                                  0xFFFFCA2B),
                                                              value: progress,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xFFFFEFBD),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                    ],
                                                  ),
                                                  SizedBox(
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
                            child: InstaImageViewer(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.file_copy_outlined,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
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
                                          pageBuilder: (BuildContext
                                                  buildContext,
                                              Animation animation,
                                              Animation secondaryAnimation) {
                                            return Center(
                                              child: Container(
                                                height: 300,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                                child: Opacity(
                                                  opacity: imageLoaded ? 1 : 0,
                                                  child: Image.file(
                                                    lampiranSuratDokter!,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: Text(
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
                                    child: Text(
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
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

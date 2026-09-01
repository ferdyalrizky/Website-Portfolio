import 'dart:io';
import 'dart:math';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_dropdown_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_acara.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_biaya.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_uang.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/klaim_biaya/list_biaya.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/theme/colors/text_style.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class FormKlaimRutinitasScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormKlaimRutinitasScreen({super.key, required this.currUser});

  @override
  State<FormKlaimRutinitasScreen> createState() =>
      _FormKlaimRutinitasScreenState();
}

class _FormKlaimRutinitasScreenState extends State<FormKlaimRutinitasScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String keperluanTerpilih = "Online";
  List<String> listKeperluanBiaya = ["Online", "Offline"];

  File? lampiranTransportasi;
  File? lampiranTransportasiKwitansi;
  File? lampiranAcara;
  File? lampiranAcaraKwitansi;

  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;
  bool hidebutton = true;
  bool hideprogress = true;
  bool isVisible = false;

  bool hidebutton1 = true;
  bool hideprogress1 = true;
  bool isVisible1 = false;

  bool hidebutton2 = true;
  bool hideprogress2 = true;
  bool isVisible2 = false;

  bool hidebutton3 = true;
  bool hideprogress3 = true;
  bool isVisible3 = false;

  DateTime tglKwitansi = DateTime.now();
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

  //Open Camera
  Future<void> getLampiranAcara() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranAcara = File(imagePicked.path);
      setState(() {
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

  Future<void> getLampiranKwitansiAcara() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranAcaraKwitansi = File(imagePicked.path);
      setState(() {
        isVisible1 = false;
        hidebutton1 = false;
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
        hideprogress1 = false;
        isVisible1 = true;
      });
    }
  }

  // lampiran Transportasi
  Future<void> getLampiranTransportasi() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranTransportasi = File(imagePicked.path);
      setState(() {
        isVisible2 = false;
        hidebutton2 = false;
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
        hideprogress2 = false;
        isVisible2 = true;
      });
    }
  }

  Future<void> getLampiranKwitansiTranportasi() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranTransportasiKwitansi = File(imagePicked.path);
      setState(() {
        isVisible3 = false;
        hidebutton3 = false;
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
        hideprogress3 = false;
        isVisible3 = true;
      });
    }
  }

  // End Lampiran transportasi

  _onSubmitBiayaBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    if (keperluanTerpilih == "Acara" && lampiranAcara == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Waduh gak bisa ya? kirim gambar dulu..."
                : "Harus lampirkan foto persetujuan",
            contentType: ContentType.failure,
          ),
        ),
      );

      return;
    }

    if (keperluanTerpilih == "Online" && lampiranAcaraKwitansi == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Waduh gak bisa ya? kirim gambar dulu..."
                : "Harus lampirkan foto kwitansi",
            contentType: ContentType.failure,
          ),
        ),
      );

      return;
    }

    if (keperluanTerpilih == "Transportasi" && lampiranTransportasi == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Waduh gak bisa ya? kirim gambar dulu..."
                : "Harus lampirkan foto persetujuan",
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

    Map<String, String> body = {};
    body = {
      'id_karyawan': widget.currUser.id.toString(),
      'nip': widget.currUser.nip.toString(),
      'jenis_klaim_biaya': keperluanTerpilih,
      'deskripsi': _formKey.currentState?.fields['deskripsi']?.value,
      'jumlah_uang': _formKey.currentState?.fields['jumlah_uang']?.value,
      if (keperluanTerpilih == "Online")
        'nama_acara': _formKey.currentState?.fields['nama_acara']?.value,
      'bisnis_id': widget.currUser.bisnisId.toString(),
      'area_kerja_id': widget.currUser.areaKerjaId.toString(),
      'disetujuhi': "0",
      'status': widget.currUser.level == 1 ? "1" : "0",
      'id_department': widget.currUser.departemen!,
    };

    if (keperluanTerpilih == "Acara") {
      body.addAll({
        'tanggal_kwitansi': DateFormat('yyyy-MM-dd').format(tglKwitansi),
      });
    } else if (keperluanTerpilih == "Transportasi") {
      body.addAll({
        'tanggal_kwitansi': DateFormat('yyyy-MM-dd').format(tglKwitansi),
      });
    }

    print(body);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/v2/klaimBiaya/store'))
        ..headers.addAll(header)
        ..fields.addAll(body);

      if (keperluanTerpilih == "Online") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'lampiran_acc', lampiranAcara!.path),
        );
      }
      if (keperluanTerpilih == "Online") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'bukti_kwitansi', lampiranAcaraKwitansi!.path),
        );
      }
      if (keperluanTerpilih == "Offline") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'lampiran_acc', lampiranTransportasi!.path),
        );
      }
      if (keperluanTerpilih == "Offline") {
        request.files.add(
          await http.MultipartFile.fromPath(
              'bukti_kwitansi', lampiranTransportasiKwitansi!.path),
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
              msg: "Buat Klaim Biaya Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListKlaimBiayaScreen(
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
              msg: "Buat Klaim Biaya Gagal",
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
        tglKwitansi = value!;
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
                'jenis_klaim_biaya': "Online",
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rutinitas",
                    style: TextStyle(
                      color: Color(0xFF121212),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  keperluanTerpilih == "Transportasi"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah bukti transportasi*",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Visibility(
                              visible: hidebutton2,
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
                                        getLampiranTransportasi();
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
                            lampiranTransportasi != null
                                ? Visibility(
                                    visible: hideprogress2,
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
                                                            "Unggah File Transportasi",
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
                              visible: isVisible2,
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
                                      "File unggahan untuk transportasi",
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
                                                      lampiranTransportasi!,
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
                                          hideprogress2 =
                                              true; // Set to false first
                                        });
                                        await getLampiranTransportasi(); // Wait for getSuratDokter to complete
                                        setState(() {
                                          hideprogress2 =
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
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )
                      : Container(),
                  CustomDropdownAndHeader(
                    header: "Tipe Pertemuan",
                    dropdownName: "jenis_klaim_biaya",
                    items: listKeperluanBiaya,
                    onChanged: (p0) {
                      setState(() {
                        keperluanTerpilih = p0 as String;
                      });
                    },
                  ),
                  if (keperluanTerpilih == "Acara") ...[
                    const CustomTextAreaAcara(
                      header: "Judul*",
                      textAreaName: "nama_acara",
                      isRequired: true,
                    ),
                  ],
                  const CustomTextAreaUang(
                    header: "Detail Lokasi*",
                    textAreaName: "jumlah_uang",
                    labelText: "",
                    isRequired: true,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 3.0,
                    ),
                    child: const Text("Tanggal Pertemuan",
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
                        left: 3.0, right: 2.0, bottom: 10),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd-MM-yyyy').format(tglKwitansi),
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
                  const CustomTextAreaBiaya(
                    header: "Deskripsi *",
                    textAreaName: "deskripsi",
                    labelText: "Ketik alasanmu....",
                    isRequired: true,
                  ),
                  keperluanTerpilih == "Online"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text: "Unggah File Online*",
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
                                        getLampiranKwitansiAcara();
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                          const Text(
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
                            lampiranAcaraKwitansi != null
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
                                                            "Unggah File Pertemuan",
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
                                      "File unggahan acara kwitansi",
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
                                                  height: 300.h,
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Opacity(
                                                    opacity:
                                                        imageLoaded ? 1 : 0,
                                                    child: Image.file(
                                                      lampiranAcaraKwitansi!,
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
                                        await getLampiranKwitansiAcara(); // Wait for getSuratDokter to complete
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
                  keperluanTerpilih == "Transportasi"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: CustomTextStyle.bodySmall,
                                children: [
                                  TextSpan(
                                      text:
                                          "Unggah bukti Transportasi Kwitansi*",
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
                              visible: hidebutton3,
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
                                        getLampiranKwitansiTranportasi();
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
                            lampiranTransportasiKwitansi != null
                                ? Visibility(
                                    visible: hideprogress3,
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
                                                            "Unggah File Transportasi Kwitansi",
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
                                                    SizedBox(
                                                      height: 15.h,
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
                              visible: isVisible3,
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
                                      "File unggah transportasi kwitansi",
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
                                                  height: 300.h,
                                                  width: double.infinity,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                  child: Opacity(
                                                    opacity:
                                                        imageLoaded ? 1 : 0,
                                                    child: Image.file(
                                                      lampiranTransportasiKwitansi!,
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
                                          hideprogress3 =
                                              true; // Set to false first
                                        });
                                        await getLampiranKwitansiTranportasi(); // Wait for getSuratDokter to complete
                                        setState(() {
                                          hideprogress3 =
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
                      'klaim biaya ini ?',
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
                            _onSubmitBiayaBtnPress();
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

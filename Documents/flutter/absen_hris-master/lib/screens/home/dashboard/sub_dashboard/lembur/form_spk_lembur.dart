// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_area_and_header.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/lembur/list_spk_lembur.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../../../../theme/colors/text_style.dart';
import '../../../../../widgets/custom_snackbar_content.dart';
import '../../../../../widgets/dialog.dart';
import '../components/custom_dropdown_and_header.dart';

class FormSpkLemburScreen extends StatefulWidget {
  final Karyawan currUser;
  const FormSpkLemburScreen({super.key, required this.currUser});

  @override
  State<FormSpkLemburScreen> createState() => _FormSpkLemburScreenState();
}

class _FormSpkLemburScreenState extends State<FormSpkLemburScreen> {
  final bool _selectAll = false;
  File? lampiranLembur;
  Uint8List? lampiranSuratLembur;
  Uint8List? watermarkedlampiranSuratLembur;
  final _formKey = GlobalKey<FormBuilderState>();
  bool isLoadingGetData = true;
  bool isLoadingGetAnakBuah = false;
  int selectedDepartment = 0;
  double progress = 0;
  bool imageLoaded = false;
  bool visibilityTag = false;
  bool hidebutton = true;
  bool hideprogress = true;
  bool isVisible = false;

  List<String> listAnakBuahString = [];
  List<String> listAnakBuahSelected = [];

  List<Department> listDepartment = [];
  List<String> listDepartmentString = [];

  DateTime tglLemburMulai = DateTime.now();
  DateTime tglLemburSelesai = DateTime.now();
  TimeOfDay jamMulaiLembur = const TimeOfDay(hour: 18, minute: 00);
  TimeOfDay jamSelesaiLembur = const TimeOfDay(hour: 21, minute: 00);

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "tag") {
        visibilityTag = visibility;
      }
    });
  }

  Future getLembur() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.gallery);
    if (imagePicked != null) {
      lampiranLembur = File(imagePicked.path);
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

  onGetDepartemenList() async {
    setState(() {
      isLoadingGetData = true;
      isLoadingGetAnakBuah = true;
    });
    listDepartment = [];
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getDepartment/${widget.currUser.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
      );
      final output = jsonDecode(response.body);
      print(output);
      for (var department in output) {
        listDepartment.add(Department.fromJson(department));
        listDepartmentString.add(department['nama_department']);
      }
    } catch (e) {
      print('ERROR ON OnGetDepartemenList');
      debugPrint(e.toString());
    }

    //

    setState(() {
      isLoadingGetData = false;
      selectedDepartment = listDepartment[0].id!;
    });
    await onGetAnakBuahList();
  }

  onGetAnakBuahList() async {
    setState(() {
      isLoadingGetAnakBuah = true;
    });

    listAnakBuahString = [];
    listAnakBuahSelected = [];
    Map<String, String> body = {
      'dept_id': selectedDepartment.toString(),
      'nip': widget.currUser.nip.toString()
    };
    try {
      var response = await http.post(
        Uri.parse('$API_URL/v2/getAnakBuah'),
        headers: {
          'Authorization': 'Bearer ${widget.currUser.apiToken}',
        },
        body: body,
      );

      final output = jsonDecode(response.body);

      for (var karyawan in output) {
        listAnakBuahString.add(karyawan);
      }
      selectedDepartment = listDepartment[0].id!;
    } catch (e) {
      print('ERROR ON OnGetAnakBuahList');
      debugPrint(e.toString());
    }

    setState(() {
      isLoadingGetAnakBuah = false;
    });
  }

  onSubmitSikBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    if (!validationSuccess) {
      return;
    } else {
      Dialogs.loading(context, keyLoader, "Proses...");
    }

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };

    Map<String, String> body = {
      "tanggal": DateFormat('yyyy-MM-dd').format(tglLemburMulai),
      "tanggal_selesai": DateFormat('yyyy-MM-dd').format(tglLemburSelesai),
      "mulai_lembur":
          "${jamMulaiLembur.hour.toString().padLeft(2, '0')}:${jamMulaiLembur.minute.toString().padLeft(2, '0')}",
      "selesai_lembur":
          "${jamSelesaiLembur.hour.toString().padLeft(2, '0')}:${jamSelesaiLembur.minute.toString().padLeft(2, '0')}",
      "keperluan": _formKey.currentState!.fields['keperluan-lembur']?.value,
      "department_id": selectedDepartment.toString(),
      "bisnis_id": widget.currUser.bisnisId.toString(),
      "creator_id": widget.currUser.id.toString(),
      "creator_level": widget.currUser.level.toString(),
    };
    for (int i = 0; i < listAnakBuahSelected.length; i++) {
      body.addAll({"nama_karyawan[$i]": listAnakBuahSelected[i]});
    }

    print(body);

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$API_URL/v2/buatSpkl'))
            ..headers.addAll(header)
            ..fields.addAll(body);

      if (lampiranLembur != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
              'bukti_lembur', lampiranLembur!.path),
        );
      }
      var response = await request.send();

      var res = await http.Response.fromStream(response);
      debugPrint(res.body);

      if (response.statusCode == 201) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Buat SPK Lembur Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ListSpkLemburScreen(
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
              msg: "Buat SPK Lembur Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDateRange:
          DateTimeRange(start: tglLemburMulai, end: tglLemburSelesai),
    );

    if (picked != null) {
      setState(() {
        tglLemburMulai = picked.start;
        tglLemburSelesai = picked.end;
      });
    }
  }

  @override
  void initState() {
    onGetDepartemenList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: isLoadingGetData
          ? const Center(
              child: Loader(),
            )
          : SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  //FocusScope.of(context).requestFocus(FocusNode());
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {'department': listDepartmentString[0]},
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 13,
                        ),
                        const Text(
                          "Lembur",
                          style: TextStyle(
                            color: Color(0xFF121212),
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        CustomDropdownAndHeader(
                          header: "Department*",
                          dropdownName: "department",
                          items: listDepartmentString,
                          onChanged: (p0) {
                            setState(() {
                              var departementGet = listDepartment.where(
                                  (element) => element.namaDepartment == p0);
                              selectedDepartment = departementGet.first.id!;
                              onGetAnakBuahList();
                            });
                          },
                        ),
                        isLoadingGetAnakBuah
                            ? const Center(
                                child: Loader(),
                              )
                            : Container(
                                margin: const EdgeInsets.only(
                                    left: 2.0, right: 2.0, bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    RichText(
                                      text: const TextSpan(
                                        style: CustomTextStyle.bodySmall,
                                        children: [
                                          TextSpan(
                                              text: "Karyawan*",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF121212))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    MultiSelectDialogField(
                                      autovalidateMode: AutovalidateMode.always,
                                      searchable: true,
                                      items: [
                                        MultiSelectItem(
                                            "Select All", "Select All"),
                                        ...listAnakBuahString
                                            .map((e) => MultiSelectItem(e, e)),
                                      ],
                                      onConfirm: (p0) {
                                        if (p0.contains("Select All")) {
                                          listAnakBuahSelected =
                                              listAnakBuahString;
                                          // Toggle selection of all items
                                          for (var item in listAnakBuahString) {
                                            if (!p0.contains(item)) {
                                              p0.add(item);
                                            }
                                          }
                                        } else {
                                          listAnakBuahSelected = p0;
                                        }

                                        MultiSelectChipDisplay(
                                          chipColor: Colors.black,
                                          textStyle: const TextStyle(
                                              color: Colors.amber),
                                        );
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Harus Diisi';
                                        }
                                        return null;
                                      },
                                      selectedColor: LightColors.kFagettiBlue,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(4),
                                        ),
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    RichText(
                                      text: const TextSpan(
                                        style: CustomTextStyle.bodySmall,
                                        children: [
                                          TextSpan(
                                              text: "Tanggal Lembur*",
                                              style: TextStyle(
                                                  color: Color(0xFF121212),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 0, right: 0, bottom: 10),
                                      padding: const EdgeInsets.only(top: 10),
                                      height: 58,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _showDateRangePicker();
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
                                              "${DateFormat('dd/MM/yyyy').format(tglLemburMulai)} -  ${DateFormat('dd/MM/yyyy').format(tglLemburSelesai)}",
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        RichText(
                                          text: const TextSpan(
                                            style: CustomTextStyle.bodySmall,
                                            children: [
                                              TextSpan(
                                                text: "Jam Mulai*",
                                                style: TextStyle(
                                                    color: Color(0xFF121212),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 0, right: 0, bottom: 10),
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          height: 58,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              TimeOfDay? newTime =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          jamMulaiLembur);
                                              if (newTime == null) return;
                                              setState(() {
                                                jamMulaiLembur = newTime;
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${jamMulaiLembur.hour.toString().padLeft(2, '0')}:${jamMulaiLembur.minute.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontSize: 16),
                                                ),
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  color: Color(0xFF000000),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: const TextSpan(
                                            style: CustomTextStyle.bodySmall,
                                            children: [
                                              TextSpan(
                                                text: "Jam Akhir*",
                                                style: TextStyle(
                                                    color: Color(0xFF121212),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 0, right: 0, bottom: 10),
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          height: 58,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              TimeOfDay? newTime =
                                                  await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          jamSelesaiLembur);
                                              if (newTime == null) return;
                                              setState(() {
                                                jamSelesaiLembur = newTime;
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "${jamSelesaiLembur.hour.toString().padLeft(2, '0')}:${jamSelesaiLembur.minute.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontSize: 16),
                                                ),
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  color: Color(0xFF000000),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const CustomTextAreaAndHeader(
                                      header: "Catatan kerja*",
                                      textAreaName: "keperluan-lembur",
                                      isRequired: true,
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
                                                  text:
                                                      "Unggah bukti lembur (opsional)",
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    getLembur();
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
                                                        style: TextStyle(
                                                            color: Colors.grey),
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
                                        lampiranLembur != null
                                            ? Visibility(
                                                visible: hideprogress,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: LightColors
                                                          .kFagettiBlue,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: LightColors
                                                            .kFagettiBlue,
                                                        offset: Offset(4, 4),
                                                      )
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .folder_rounded,
                                                            size: 32,
                                                            color: LightColors
                                                                .kFagettiBlue,
                                                          ),
                                                          const SizedBox(
                                                              width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              20),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      const Text(
                                                                        "Unggah File Lembur",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            visibilityTag =
                                                                                !visibilityTag;
                                                                            _changed(visibilityTag,
                                                                                "tag");
                                                                            Future.delayed(const Duration(milliseconds: 50)); // Add delay here
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.only(top: 16.0),
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  "${(progress * 101).toStringAsFixed(0)} %",
                                                                                  style: Theme.of(context).textTheme.bodySmall,
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.only(top: 8.0),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              8,
                                                                          child:
                                                                              LinearProgressIndicator(
                                                                            color:
                                                                                const Color(0xFFFFCA2B),
                                                                            value:
                                                                                progress,
                                                                            backgroundColor:
                                                                                const Color(0xFFFFEFBD),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
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
                                                  "File unggahan untuk lembur",
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
                                                        barrierDismissible:
                                                            true,
                                                        barrierLabel:
                                                            MaterialLocalizations
                                                                    .of(context)
                                                                .modalBarrierDismissLabel,
                                                        barrierColor:
                                                            Colors.black87,
                                                        transitionDuration:
                                                            const Duration(
                                                                milliseconds:
                                                                    0),
                                                        pageBuilder: (BuildContext
                                                                buildContext,
                                                            Animation animation,
                                                            Animation
                                                                secondaryAnimation) {
                                                          return Center(
                                                            child: Container(
                                                              height: 300,
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                              ),
                                                              child: Opacity(
                                                                opacity:
                                                                    imageLoaded
                                                                        ? 1
                                                                        : 0,
                                                                child:
                                                                    Image.file(
                                                                  lampiranLembur!,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  child: const Text(
                                                    'Lihat',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      hideprogress =
                                                          true; // Set to false first
                                                    });
                                                    await getLembur(); // Wait for getSuratDokter to complete
                                                    setState(() {
                                                      hideprogress =
                                                          false; // Set to true after completion
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Ubah',
                                                    style: TextStyle(
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
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
                      'lembur ini ?',
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
                            onSubmitSikBtnPress();
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
